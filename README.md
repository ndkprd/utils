# ndkprd's utils

Random bash/python utility/hacks I made for various daily tasks.

## List of Utils

### [k8s-manifests-cleaner.sh](./k8s-manifests-cleaner.sh)

Remove server-side generated Kubernetes fields from manifests yaml file.

Usage:

```bash
./k8s-manifests-cleaner.sh /path/to/parent/dir
```

### [k8s-kustomize-generator.sh](./k8s-kustomize-generator)

Generate separate kustomize files based on joined YAML files/templated Helm charts. For usage, check the [repo](https://github.com/ndkprd/k8s-kustomize-generator).

## LICENSE

[MIT](./LICENSE)
