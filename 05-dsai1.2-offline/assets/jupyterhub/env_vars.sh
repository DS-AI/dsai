#!/bin/bash
export PATH=`echo -e 'import sys\nprefix = "/opt/pbis/bin/"\nprint(prefix + ":" + ":".join([p for p in sys.argv[1].split(":") if p != prefix]))' | python - ${PATH}`
