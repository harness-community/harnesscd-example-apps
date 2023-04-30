# Blue Green

The blue green strategy is not supported by built-in Kubernetes Deployment but available via third-party Kubernetes controller.
This example demonstrates how to implement blue-green deployment via [Harness Rollouts](https://github.com/harnessproj/harness-rollouts):

1. Install Harness Rollouts controller: https://github.com/harnessproj/harness-rollouts#installation
2. Create a sample application and sync it.

```
harnesscd app create --name blue-green --repo https://github.com/harnessproj/harnesscd-example-apps --dest-server https://kubernetes.default.svc --dest-namespace default --path blue-green && harnesscd app sync blue-green
```

Once the application is synced you can access it using `blue-green-helm-guestbook` service.

3. Change image version parameter to trigger blue-green deployment process:

```
harnesscd app set blue-green -p image.tag=0.2 && harnesscd app sync blue-green
```

Now application runs `ks-guestbook-demo:0.1` and `ks-guestbook-demo:0.2` images simultaneously.
The `ks-guestbook-demo:0.2` is still considered `blue` available only via preview service `blue-green-helm-guestbook-preview`.

4. Promote `ks-guestbook-demo:0.2` to `green` by patching `Rollout` resource:

```
harnesscd app patch-resource blue-green --kind Rollout --resource-name blue-green-helm-guestbook --patch '{ "status": { "verifyingPreview": false } }' --patch-type 'application/merge-patch+json'
```

This promotes `ks-guestbook-demo:0.2` to `green` status and `Rollout` deletes old replica which runs `ks-guestbook-demo:0.1`.
