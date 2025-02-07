# ndkprd's utils

Random bash/python utility/hacks I made for various daily tasks.

## List of Utils

### [k8s-manifests-cleaner.sh](./k8s-manifests-cleaner.sh)

Remove server-side generated Kubernetes fields from manifests yaml file.

Usage:

```bash
./k8s-manifests-cleaner.sh /path/to/parent/dir
```

### [k8s-yaml-mark-adder.sh](./k8s-yaml-mark-adder.sh)

For those who have this itch when they see a yaml file without "---" header.

Usage:

```bash
./k8s-yaml-mark-adder.sh /path/to/parent/dir
```

### [k8s-kustomize-generator.py](https://github.com/ndkprd/kustomize-generator)

Generate separate kustomize files based on joined YAML files/templated Helm charts. For usage, check the [repo](https://github.com/ndkprd/kustomize-generator).

## LICENSE

[MIT](./LICENSE)
