## What is Event Relay?

**Event Relay** is a type of trigger in Harness that allows you to integrate with external systems to dynamically trigger pipelines based on custom events sent via HTTP. It works by receiving JSON-formatted event payloads through a webhook endpoint, processing the event, and starting the configured pipeline execution.

This feature is useful for connecting Harness pipelines to external systems, artifact registries, and container registries.

## Steps to Set Up an Event Relay Pipeline

1. **Create a Webhook**:
   - Navigate to the **Settings** in the Harness UI.
   - Go to **Webhooks** and click **New Webhook**.
   - Choose the type of webhook you want to create:
     - **Git Webhook**: Activates triggers based on Git events. For more information, see [Trigger pipelines using Git events](https://developer.harness.io/docs/platform/triggers/triggering-pipelines).
     - **Generic Webhook**: Activates triggers based on generic events, such as changes in an artifact repository. For more information, see [EventRelay Generic Webhook triggers](https://developer.harness.io/docs/platform/triggers/trigger-pipelines-using-generic-events/).
     - **Slack Webhook**: Activates triggers based on Slack events. For more information, see [EventRelay Slack Webhook triggers](https://developer.harness.io/docs/platform/triggers/trigger-pipelines-using-slack-events).
   - Once the webhook is created, copy the webhook URL. This webhook URL serves as a listener and can be placed in your third-party application or artifact registry to send events.

2. **Define an Event Relay Trigger**:
   - Navigate to your pipeline and click **Triggers** in the top-right corner.
   - Under the **Trigger Listing** tab, click **+ New Trigger**.
   - Select **Event Relay** as the webhook type.
   - In the **Configuration** tab, select the webhook you created earlier.
   - In the **Conditions** tab, specify the conditions for running the pipeline.
   - Click **Create Trigger**.

3. **Test the Trigger**:
   - Use tools like Postman or cURL to send a sample event payload to the webhook URL.
   - Verify that the pipeline is triggered and that the inputs are processed correctly.

4. **Monitor Execution**:
   - Review pipeline execution logs and outputs to ensure the Event Relay pipeline is functioning as expected.


## Example Use Case

There are no limitations on the webhook side; it listens to any event sent to the webhook URL.

However, there may be limitations on the third-party sources regarding the types of events that can be sent to the webhook. Let’s explore some common use cases:

### 1. Artifactory Trigger When Files Are Uploaded to a Subfolder

This can be achieved with Nexus 3 Artifactory.

1. Navigate to the **Settings** in your Nexus 3 instance.
2. Under **System**, go to **Capabilities**.
3. Click on **Create Capability** and select **Webhook: Global**.

   **Webhook: Global** sends HTTP POST requests for global events.

4. In the **Settings** tab of the capability, under the **Event Type**, you have two options:
   - **Asset**: This tracks changes to artifacts.
   - **Component**: This tracks changes to the logical entities representing artifacts (e.g., Docker images, Maven libraries).

   The **Repository** event type triggers the webhook when specific changes occur in a repository (focused on changes to artifacts stored in repositories).
   
   The **Audit** event type focuses on changes to the Nexus system configuration (e.g., user activity or administrative changes), not changes to artifacts in repositories.

   - Select **Repository event** if you want to track events related to changes in artifacts stored in repositories.
   - Select **Audit event** if you want to track all activity within the organization.

5. Under **URL**, paste your webhook URL.


### 2. Artifact Trigger When the SHA/Checksum of the Image Changes

This can also be achieved with Nexus 3 Artifactory.

1. Navigate to the **Settings** in your Nexus 3 instance.
2. Under **System**, go to **Capabilities**.
3. Click on **Create Capability** and select **Webhook: Repository**.

   **Webhook: Repository** sends HTTP POST requests for repository events.

4. In the **Settings** tab of the capability, under the **Event Type**, you have two options:
   - **Component**: Represents logical entities (e.g., Docker images).
   - **Asset**: Represents the physical files or binaries associated with those artifacts.

   - Select **Component** to track when a new image or tag is pushed.
   - Select **Asset** to track the metadata of a tag that is pushed. If you push the same image with the same tag and still want to trigger an event, choose **Asset**.

5. Under **URL**, paste your webhook URL.


### 3. Trigger on New Artifact Support for Folders

This can also be achieved with Nexus 3 Artifactory.

1. Navigate to the **Settings** in your Nexus 3 instance.
2. Under **System**, go to **Capabilities**.
3. Click on **Create Capability** and select **Webhook: Global**.

   **Webhook: Global** sends HTTP POST requests for global events.

4. In the **Settings** tab of the capability, under the **Event Type**, you have two options:
   - **Repository event**: Tracks changes to artifacts stored in repositories.

5. In the **Trigger Settings**, under **Conditions**, you can configure the folder name where you want to detect changes.


### 4. Google Pub/Sub Trigger Support: NPM Google Artifact Registry, Generic Google Artifact Registry, OCI Helm registry 

This is possible using **Google Cloud Platform's Pub/Sub service**.

1. In the **Google Cloud Platform Console**, navigate to **Pub/Sub**.
2. Under **Topics**, create a new topic.
3. Under the **Topic**, create a new subscription. In the **Delivery Type** of the subscription, select **Push**, and paste your webhook URL in the **Endpoint URL** field. Click **Save**.
4. Navigate back to the topic you created, and under the **Messages** tab, click **Step-1: Publish Message**.
5. Paste a sample payload and click **Publish** to verify that your webhook can listen to the event.

For more information on creating a topic and subscription, refer to the [Pub/Sub Documentation](https://cloud.google.com/pubsub/docs/publish-message-overview).

**Note**: For using an OCI Helm registry with Google Artifact Registry, refer to the [Google Docs on Helm](https://cloud.google.com/artifact-registry/docs/helm).


#### Linking Google Artifact Registry to Your Subscription

You can link the Google Artifact Registry to your subscription using various methods:

1. **Cloud Audit Logs**:  
   Fetch logs related to changes in the Artifact Registry using **Cloud Audit Logs**. Set up a **Log Sink** in **Logs Router** to capture these logs and send them to the Pub/Sub subscription.
   
2. **Google Cloud Build Triggers**:  
   Use **Google Cloud Build** triggers, which can activate based on changes in Artifact Registry, such as when new tags are pushed to images.
   
3. **Cloud Functions or Cloud Run**:  
   Implement an event-driven architecture by using **Pub/Sub** in combination with services like **Cloud Functions** or **Cloud Run** to react to changes.


### 5. Ability to Use Any Repo Name in Pipeline Webhook Trigger

Harness supports **organization-wide GitHub webhooks**, enabling you to trigger pipelines from **any repository**. You can further refine which repositories trigger your pipeline by **filtering** on the **Header**, **Payload**, or using **JEXL** conditions.

For more information on setting up an organization-wide GitHub webhook, see the [GitHub Documentation](https://docs.github.com/en/webhooks/using-webhooks/creating-webhooks#creating-an-organization-webhook).

**Note:** You must have **Org Owner** permissions in GitHub to create organization-level webhooks.