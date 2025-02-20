# ndkprd's utils

Random bash/python utility/hacks I made for various daily tasks.

## Usage

### [k8s_manifests_cleaner.sh](./k8s_manifests_cleaner.sh)

Remove server-side generated Kubernetes fields from manifests yaml file. Require [yq](https://github.com/mikefarah/yq).

Usage:

```bash
./k8s-manifests-cleaner.sh /path/to/parent/dir
```

### [k8s_yaml_mark_adder.sh](./k8s_yaml_mark_adder.sh)

For those who have this itch when they see a yaml file without "---" header. Require [yq](https://github.com/mikefarah/yq).

Usage:

```bash
./k8s-yaml-mark-adder.sh /path/to/parent/dir
```

### [k8s-kustomize-generator.py](https://github.com/ndkprd/kustomize-generator)

Generate separate kustomize files based on joined YAML files/templated Helm charts. For usage, check the [repo](https://github.com/ndkprd/kustomize-generator).

### [log_cleaner.sh](./log_cleaner.sh)

Clean up logs older than certain days.

Usage:

Since this is mostly used by cron, the directory list and retention days is hardcoded into the script. Don't forget to modify as you need.

```bash
./log-cleaner.sh
```

### [openshift_loginer.sh](./openshift_loginer.sh)

Do `oc login` to multiple clusters at once. Really useful if you work with multiple contexts using [k9s](https://github.com/derailed/k9s).

```bash
./oc-loginer.sh
# after running the script, you will be prompted for username and password.
```

## LICENSE

[MIT](./LICENSE)
