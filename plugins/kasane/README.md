# Kasane

[Kasane](https://github.com/google/kasane) is a layering tool for Kubernetes which utilises Jsonnet for deep object modification and patching.

Use following steps to try the application:

* Follow instructions from [custom_tools.md](https://github.com/harnessproj/harness-cd/blob/master/docs/operator-manual/custom_tools.md) to make sure `kasane` binary is available in `harnesscd-repo-server` pod.
* Register `kasane` plugin `harnesscd-cm` ConfigMap:

```yaml
apiVersion: v1
data:
  configManagementPlugins: |
    - name: kasane
      init:
        command: [kasane, update]
      generate:
        command: [kasane, show]
```
* Create application using `kasane` as a config management plugin name.

```
harnesscd app create kasane \
    --config-management-plugin kasane \
    --repo https://github.com/harnessproj/harnesscd-example-apps \
    --path plugins/kasane \
    --dest-server https://kubernetes.default.svc \
    --dest-namespace default
```
