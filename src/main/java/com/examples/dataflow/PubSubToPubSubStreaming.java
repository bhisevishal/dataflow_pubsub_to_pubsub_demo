package com.examples.dataflow;

import org.apache.beam.runners.dataflow.options.DataflowPipelineOptions;
import org.apache.beam.sdk.Pipeline;
import org.apache.beam.sdk.io.gcp.pubsub.PubsubIO;
import org.apache.beam.sdk.options.Description;
import org.apache.beam.sdk.options.PipelineOptionsFactory;
import org.apache.beam.sdk.options.Validation;

/**
 * A Dataflow pipeline that reads messages from a Pub/Sub subscription or topic and writes them to
 * another Pub/Sub topic.
 */
public class PubSubToPubSubStreaming {

  /** Custom pipeline options for the PubSubToPubSubStreaming pipeline. */
  public interface PubSubToPubSubOptions extends DataflowPipelineOptions {
    @Description("The Cloud Pub/Sub subscription to read from. Required if inputTopic is not set.")
    String getInputSubscription();

    void setInputSubscription(String value);

    @Description("The Cloud Pub/Sub topic to read from. Required if inputSubscription is not set.")
    String getInputTopic();

    void setInputTopic(String value);

    @Description("The Cloud Pub/Sub topic to write to.")
    @Validation.Required
    String getOutputTopic();

    void setOutputTopic(String value);

    @Description(
        "Optional. The name of the Pub/Sub message attribute to use for the message ID. If"
            + " provided, this attribute will be read from incoming messages and set on outgoing"
            + " messages. If not specified, Pub/Sub's system-generated ID and behavior are used.")
    String getMessageIdAttribute();

    void setMessageIdAttribute(String value);

    @Description(
        "Optional. The name of the Pub/Sub message attribute to use for the event timestamp (RFC"
            + " 3339 format). If provided, this attribute will be read from incoming messages (to"
            + " set the element's event time) and set on outgoing messages (with the element's"
            + " event time). If not specified, the Pub/Sub message's publish time is used for"
            + " incoming messages, and no custom timestamp attribute is set for outgoing messages.")
    String getTimestampAttribute();

    void setTimestampAttribute(String value);
  }

  public static void main(String[] args) {
    // Create and configure pipeline options
    PubSubToPubSubOptions options =
        PipelineOptionsFactory.fromArgs(args).withValidation().as(PubSubToPubSubOptions.class);

    // Validate that either inputSubscription or inputTopic is provided, but not both.
    boolean hasInputSubscription =
        options.getInputSubscription() != null && !options.getInputSubscription().isEmpty();
    boolean hasInputTopic = options.getInputTopic() != null && !options.getInputTopic().isEmpty();

    if (hasInputSubscription && hasInputTopic) {
      throw new IllegalArgumentException(
          "Either inputSubscription or inputTopic must be set, but not both.");
    }
    if (!hasInputSubscription && !hasInputTopic) {
      throw new IllegalArgumentException("Either inputSubscription or inputTopic must be set.");
    }

    // Create the pipeline
    Pipeline pipeline = Pipeline.create(options);

    // Configure Pub/Sub read operation
    PubsubIO.Read<String> pubsubRead = PubsubIO.readStrings();
    if (hasInputSubscription) {
      pubsubRead = pubsubRead.fromSubscription(options.getInputSubscription());
    } else { // hasInputTopic must be true due to the checks above
      pubsubRead = pubsubRead.fromTopic(options.getInputTopic());
    }

    if (options.getMessageIdAttribute() != null && !options.getMessageIdAttribute().isEmpty()) {
      pubsubRead = pubsubRead.withIdAttribute(options.getMessageIdAttribute());
    }
    if (options.getTimestampAttribute() != null && !options.getTimestampAttribute().isEmpty()) {
      pubsubRead = pubsubRead.withTimestampAttribute(options.getTimestampAttribute());
    }

    // Configure Pub/Sub write operation
    PubsubIO.Write<String> pubsubWrite = PubsubIO.writeStrings().to(options.getOutputTopic());

    if (options.getMessageIdAttribute() != null && !options.getMessageIdAttribute().isEmpty()) {
      pubsubWrite = pubsubWrite.withIdAttribute(options.getMessageIdAttribute());
    }
    if (options.getTimestampAttribute() != null && !options.getTimestampAttribute().isEmpty()) {
      pubsubWrite = pubsubWrite.withTimestampAttribute(options.getTimestampAttribute());
    }

    // Apply the configured read and write operations to the pipeline
    pipeline
        .apply("ReadFromPubSubSubscription", pubsubRead)
        .apply("WriteToPubSubTopic", pubsubWrite);

    // Run the pipeline.
    // For a Dataflow Flex Template, or when running on the Dataflow service,
    // waitUntilFinish is not called. The runner will manage the pipeline's lifecycle.
    pipeline.run();
  }
}
