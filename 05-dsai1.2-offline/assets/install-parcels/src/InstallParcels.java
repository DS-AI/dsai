import com.cloudera.api.ClouderaManagerClientBuilder;
import com.cloudera.api.DataView;
import com.cloudera.api.model.*;
import com.cloudera.api.v1.ClustersResource;
import com.cloudera.api.v18.ClustersResourceV18;
import com.cloudera.api.v19.ClouderaManagerResourceV19;
import com.cloudera.api.v19.RootResourceV19;
import com.cloudera.api.v3.ParcelResource;
import com.cloudera.api.v5.ParcelsResourceV5;

import java.util.Collections;
import java.util.Date;

public class InstallParcels {
    private static boolean waitToComplete(RootResourceV19 api, ApiCommand command, long pause, String waitMessage) {
        boolean isFirstAttempt = true;
        while (true) {
            Boolean success = command.getSuccess();
            if (success == null) {
                try {
                    Thread.sleep(pause);
                } catch (InterruptedException ex) {
                    ex.printStackTrace();
                }

                command = api.getCommandsResource().readCommand(command.getId());

                if (isFirstAttempt) {
                    isFirstAttempt = false;
                } else {
                    System.out.println(waitMessage);
                }
            } else {
                return success;
            }
        }
    }

    private static boolean installParcel(
            RootResourceV19 api,
            ParcelsResourceV5 parcels,
            String product,
            String version,
            long pause)
    {
        ParcelResource parcel = parcels.getParcelResource(product, version);

        boolean result = parcel.startDownloadCommand().getSuccess();
        System.out.println("Started downloading " + product + "-" + version + " parcel: " + (result ? "SUCCESS" : "FAILURE"));
        if (!result) {
            return false;
        }

        while ("DOWNLOADING".equals(parcel.readParcel().getStage())) {
            try {
                Thread.sleep(pause);
            } catch (InterruptedException ex) {
                ex.printStackTrace();
            }

            System.out.println("Waiting for " + product + "-" + version + " parcel to download...");
        };

        System.out.println("Downloaded " + product + "-" + version + " parcel.");

        result = parcel.startDistributionCommand().getSuccess();
        System.out.println("Started distributing " + product + "-" + version + " parcel: " + (result ? "SUCCESS" : "FAILURE"));
        if (!result) {
            return false;
        }

        while ("DISTRIBUTING".equals(parcel.readParcel().getStage())) {
            try {
                Thread.sleep(pause);
            } catch (InterruptedException ex) {
                ex.printStackTrace();
            }

            System.out.println("Waiting for " + product + "-" + version + " parcel to distribute...");
        };

        System.out.println("Distributed " + product + "-" + version + " parcel.");

        result = parcel.activateCommand().getSuccess();
        System.out.println("Activate " + product + "-" + version + " parcel: " + (result ? "SUCCESS" : "FAILURE"));
        if (!result) {
            return false;
        }

        while ("ACTIVATING".equals(parcel.readParcel().getStage())) {
            try {
                Thread.sleep(pause);
            } catch (InterruptedException ex) {
                ex.printStackTrace();
            }

            System.out.println("Waiting for " + product + "-" + version + " parcel to activate...");
        };

        System.out.println("Activated " + product + "-" + version + " parcel.");

        return true;
    }

    public static void main(String[] args) {
        RootResourceV19 api = new ClouderaManagerClientBuilder().withHost("localhost")
                .withUsernamePassword("admin", "admin").build().getRootV19();

        long pause = 10000;
	String echoIn = "ping";
	while (true) {
	    String echoOut = null;
	    try {
		echoOut = api.getToolsResource().echo(echoIn).getMessage();
	    } catch (Exception e) {
		// Deliberately doing nothing
	    }

	    if (echoIn.equals(echoOut)) {
		System.out.println("Server is up.");

		break;
	    }

	    try {
		Thread.sleep(pause);
	    } catch (InterruptedException ex) {
		ex.printStackTrace();
	    }

	    System.out.println("Waiting for the server to start...");
	}

        long threshold = 15000;
        ApiHost localHost;
outer:
        while (true) {
            ApiHostList hostList = api.getHostsResource().readHosts(DataView.FULL);

            for (ApiHost host : hostList.getHosts()) {
                if ("127.0.0.1".equals(host.getIpAddress())) {
                    localHost = host;
                    Date lastHeartbeat = localHost.getLastHeartbeat();
                    if (lastHeartbeat != null
                            && System.currentTimeMillis() - lastHeartbeat.getTime() < threshold)
                    {
                        System.out.println("Agent is up.");

                        break outer;
                    }
                }
            }

            try {
                Thread.sleep(pause);
            } catch (InterruptedException ex) {
                ex.printStackTrace();
            }

            System.out.println("Waiting for the agent to start...");
        }

        ClouderaManagerResourceV19 clouderaManager = api.getClouderaManagerResource();

        boolean result = waitToComplete(
                api,
                clouderaManager.refreshParcelRepos(),
                pause,
                "Waiting for the parcel repos to refresh..."
        );
        System.out.println("Refresh parcel repos: " + (result ? "SUCCESS" : "FAILURE"));
        if (!result) {
            System.exit(1);
        }

        String clusterName = "local";

        ClustersResourceV18 clusters = api.getClustersResource();
        ApiCluster cluster = new ApiCluster();
        cluster.setName(clusterName);
        cluster.setFullVersion(args[0]);

        clusters.createClusters(new ApiClusterList(Collections.singletonList(cluster)));

        clusters.addHosts(
                clusterName,
                new ApiHostRefList(Collections.singletonList(new ApiHostRef(localHost.getHostId())))
        );

        ParcelsResourceV5 parcels = clusters.getParcelsResource(clusterName);
        for (int i = 1; i < args.length; i += 2) {
            result = installParcel(api, parcels, args[i], args[i + 1], pause);
            if (!result) {
                System.exit(1);
            }
        }

        System.out.println("Done.");
    }
}

