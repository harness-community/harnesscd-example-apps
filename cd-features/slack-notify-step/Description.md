# Slack Notify Step

This topic describes the settings for the Slack Notify step available in Continuous Delivery (CD) and custom stages.

The Slack Notify step lets you easily send notifications to slack channel and slack threads during a pipeline execution.

## Pipeline Overview

This pipeline is designed to send notifications to slack channel and slack threads during a pipeline execution.

## Key Files and Their Purpose 

- [**`slack-notify-step/pipeline.yaml`**](https://github.com/harness-community/harnesscd-example-apps/blob/master/cd-features/slack-notify-step/pipeline.yaml): Harness pipeline YAML for Azure Function deployment.

## Setting Up a Slack Notify Step

![](https://github.com/harness-community/harnesscd-example-apps/blob/master/cd-features/static/slack-notify-step.png)

Follow the steps below to set up a Slack notify step:

1. **Create Pipeline**  
   - Click on **Create Pipeline** and type in your pipeline name.

2. **Add Stage**  
   - Click on **Add Stage**. You can select any stage as this step is available across stages.

3. **Navigate to Execution Tab**  
   - Within the stage, go to the **Execution** tab.

4. **Add a Step Group**  
   - Add a step group.
   - Enable **Container Based Execution** by setting it to `true`.
   - Select a **Kubernetes Cluster**.
   - Save the step group.

5. **Add Slack Notify Step**  
   - Within the step group, add a step.
   - Select **Slack Notify** under **Miscellaneous**.

6. **Configure Slack Notify Step**  
   - Select the **Channel** checkbox or the **Email** checkbox.
   - For sending notifications to a channel, provide the channel details where you want your message to be published.
   - For sending notifications to an email address, provide the email details where you want your message to be published.
   - Optionally, send a custom text message or a Slack block.
   - Under **Slack Secret Key**, create or select your Slack secret key.
   - Optionally, specify the thread in which you want the notification to be received.

7. **Save and Run**  
   - Save your pipeline configuration and run the pipeline.

## Types of Recipients Supported:

- **Email**: The email address associated with the Slack account. This can be used to send notifications to a specific recipient.
- **Channel**: The channel where the notification is to be sent. Provide the **channel-id** of the channel.

## Types of Messages Supported:

- **Message**: A plain text format. This can be a fixed value, runtime input, or an expression.
- **Block**: You can send Slack Block notifications. Ensure that the block is enclosed in an array. For more information on Slack Blocks, refer to [Slack documentation](https://api.slack.com/reference/block-kit/blocks#header).

For more information and intractive guide on how to set-up the Slack Notify Step, refer [Harness Documentation](https://developer.harness.io/docs/continuous-delivery/x-platform-cd-features/cd-steps/utilities/slack-notify-step/)
