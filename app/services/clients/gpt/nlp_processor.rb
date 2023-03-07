# frozen_string_literal: true

require 'openai'
require 'debug'
require 'tokenizer'

module Clients
  module Gpt
    class NlpProcessor
      def initialize()
        @embeddings_model = 'text-embedding-ada-002'
        @client = OpenAI::Client.new(access_token: ENV.fetch('GPT_KEY', nil))
        @document_chunks = split_document_into_chunks
        @document_embeddings = generate_document_embeddings
      end

      def process_question(question)
        question_embedding = @client.embeddings(parameters: { model: @embeddings_model, input: question })["data"].first['embedding']
        similarities = calculate_similarities(question_embedding)
        highest_similarity_index = similarities.each_with_index.max[1]
        get_answer_from_chunk(highest_similarity_index, question)
      end

      private

      def get_answer_from_chunk(chunk_index, question)
        chunk_text = @document_chunks[chunk_index][:text]
        response = @client.completions(
          parameters: {
            model: "text-davinci-003",
            prompt: "Context: \n#{chunk_text}\n\nQuestion: #{question}\nIf you don't know the answer please return 'I could not find an answer to your question.'",
            max_tokens: 200
          }
        )
        choices = response['choices']
        answer_text = choices.pluck('text').join
        answer_text.strip.gsub(/^"/, '').gsub(/"$/, '').gsub(/^'/, '').gsub(/'$/, '')
      end

      def calculate_similarities(question_embedding)
        @document_embeddings.map do |embedding|
          cosine_similarity(embedding, question_embedding)
        end
      end

      def generate_document_embeddings
        # current_data = Rails.cache.read("document_tokens")

        # if current_data.present?
        #   return current_data
        # end

        total_chunks = @document_chunks.size
        current_chunk = 1
        data = @document_chunks.map do |chunk|
          puts "========== Processing chunk #{current_chunk} of #{total_chunks}"
          response = @client.embeddings(
            parameters: { model: @embeddings_model, input: chunk[:text] }
          )

          response['data']&.first['embedding'] || []
        end

        Rails.cache.write("document_tokens", data)
        data
      end

      def split_document_into_chunks
        tokenizer = Tokenizer::WhitespaceTokenizer.new

        # split the document into chunks of 3,000 tokens each
        document_chunks = []
        chunk_size = 3000
        document_tokens = tokenizer.tokenize(document)

        num_chunks = (document_tokens.size / chunk_size.to_f).ceil
        num_chunks.times do |i|
          start_index = i * chunk_size
          end_index = start_index + chunk_size
          chunk_text = document_tokens[start_index...end_index].join(' ')
          document_chunks << { embeddings: [], text: chunk_text }
        end
        document_chunks
      end

      def cosine_similarity(embedding1, embedding2)
        dot_product = embedding1.zip(embedding2).map { |a, b| a * b }.sum
        magnitude1 = Math.sqrt(embedding1.sum { |x| x**2 })
        magnitude2 = Math.sqrt(embedding2.sum { |x| x**2 })
        dot_product / (magnitude1 * magnitude2)
      end

      def document
        @contents ||= File.read("/app/notiondata.txt")
      end
    end
  end
end
