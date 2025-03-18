# Technical Specification: Customer Support & Research Assistant MVP

## Executive Summary

The Customer Support & Research Assistant MVP is a Ruby on Rails application that showcases the integration of OpenAI's agent capabilities, demonstrating multi-agent orchestration and the use of built-in tools for various support scenarios.

### Key Technical Components

1. **System Architecture**
   - Rails 7 MVC application with service-oriented architecture
   - Agent orchestration pattern for managing specialized AI agents
   - Real-time chat interface using Turbo/Hotwire
   - PostgreSQL database with JSON capabilities for flexible data storage

2. **Agent Implementation**
   - Triage Agent that analyzes and routes user queries
   - Knowledge Agent that retrieves information from internal documents
   - Research Agent that searches the web for current information
   - Support Ticket Agent that automates ticket creation
   - Extensible architecture for additional agent types

3. **OpenAI Integration**
   - Responses API with tools integration
   - File search for knowledge base retrieval
   - Web search for external information
   - Computer use for automated form completion
   - Robust error handling and rate limiting

4. **Development & Deployment**
   - Comprehensive testing strategy with RSpec
   - Security-first approach with proper credential management
   - Deployment options for various hosting environments
   - Monitoring and logging for production stability
   - Extensibility patterns for future development

## 1. System Architecture

### High-Level System Design

The application follows a service-oriented architecture within the Rails MVC framework:

1. **Web Interface Layer**: Rails controllers and views using Turbo/Hotwire
2. **Agent Orchestration Layer**: Service objects managing flow between agents
3. **Agent Services Layer**: Individual agent implementations using OpenAI's API
4. **Data Persistence Layer**: PostgreSQL database 
5. **External Integration Layer**: API clients for OpenAI and help desk system

### Data Flow Diagram

```
+----------------+     +-------------------+     +----------------+
|                |     |                   |     |                |
|   Web Browser  +---->+  Rails Controller +---->+ Orchestrator   |
|                |     |                   |     |                |
+----------------+     +-------------------+     +-------+--------+
                                                         |
                                                         v
+----------------+     +-------------------+     +-------+--------+
|                |     |                   |     |                |
| OpenAI API     <-----+  Agent Services   <-----+ Triage Agent   |
| (with tools)   |     |                   |     |                |
+----------------+     +-------------------+     +----------------+
                              |
                              v
                       +------+-------+
                       |              |
                       |  Database    |
                       |              |
                       +--------------+
```

## 2. Technology Stack

### Core Technologies

| Component | Technology | Version | Purpose |
|-----------|------------|---------|---------|
| Programming Language | Ruby | 3.2.0+ | Primary language |
| Web Framework | Ruby on Rails | 7.0.0+ | Application framework |
| Database | PostgreSQL | 14.0+ | Relational database with JSON support |
| Frontend Framework | Hotwire (Turbo & Stimulus) | Latest | Real-time updates |
| CSS Framework | TailwindCSS | 3.0+ | UI styling |
| HTTP Client | Faraday | 2.0+ | API requests |
| Testing Framework | RSpec | 3.12+ | Testing |

### Ruby Gems

```ruby
# Key gems
gem 'rails', '~> 7.0.0'
gem 'pg', '~> 1.5'
gem 'turbo-rails'
gem 'stimulus-rails'
gem 'tailwindcss-rails'
gem 'ruby-openai', '~> 5.0'
gem 'faraday', '~> 2.7'
gem 'dotenv-rails', '~> 2.8'
gem 'lograge', '~> 0.12'
```

## 3. Database Design

### Entity-Relationship Diagram

```
+-------------------+       +-------------------+       +-------------------+
|  SupportSession   |       |      Message      |       |    AgentTrace     |
+-------------------+       +-------------------+       +-------------------+
| id                |<------| support_session_id|       | id                |
| user_id (optional)|       | id                |<------| message_id        |
| created_at        |       | content           |       | agent_type        |
| updated_at        |       | role              |       | input_data        |
+-------------------+       | metadata          |       | output_data       |
         |                  | created_at        |       | created_at        |
         |                  | updated_at        |       | updated_at        |
         |                  +-------------------+       +-------------------+
         |
         |                  +-------------------+
         |                  | KnowledgeDocument |
         |                  +-------------------+
         |                  | id                |
         |                  | title             |
         |                  | content           |
         |                  | metadata          |
         |                  | vector_store_id   |
         |                  +-------------------+
         |
         |                  +-------------------+
         +----------------->|   SupportTicket   |
                            +-------------------+
                            | id                |
                            | support_session_id|
                            | external_ticket_id|
                            | status            |
                            | metadata          |
                            +-------------------+
```

## 4. API Integrations

### OpenAI API Integration

```ruby
# config/initializers/openai.rb
require 'openai'

OpenAI.configure do |config|
  config.access_token = ENV.fetch('OPENAI_API_KEY')
  config.organization_id = ENV.fetch('OPENAI_ORGANIZATION_ID', nil)
  config.uri_base = ENV.fetch('OPENAI_URI_BASE', 'https://api.openai.com')
  config.request_timeout = ENV.fetch('OPENAI_REQUEST_TIMEOUT', 60).to_i
end
```

### OpenAI Client Wrapper

```ruby
# app/lib/openai_client.rb
class OpenaiClient
  class Error < StandardError; end
  class RateLimitError < Error; end
  class ServerError < Error; end
  class ClientError < Error; end

  attr_reader :client

  def initialize
    @client = OpenAI::Client.new
  end

  def create_response(messages:, tools: nil, model: nil, temperature: nil)
    with_error_handling do
      client.responses.create(
        model: model || default_model,
        messages: messages,
        tools: tools,
        temperature: temperature || default_temperature
      )
    end
  end

  private

  def with_error_handling
    retries = 0
    begin
      yield
    rescue OpenAI::RateLimitError => e
      Rails.logger.error("OpenAI Rate Limit: #{e.message}")
      raise RateLimitError, "Rate limit exceeded: #{e.message}"
    rescue OpenAI::ServerError => e
      Rails.logger.error("OpenAI Server Error: #{e.message}")
      # Retry with exponential backoff for server errors
      if retries < 3
        retries += 1
        sleep_time = 2**retries
        Rails.logger.info("Retrying after #{sleep_time} seconds...")
        sleep(sleep_time)
        retry
      end
      raise ServerError, "Server error: #{e.message}"
    rescue OpenAI::ClientError => e
      Rails.logger.error("OpenAI Client Error: #{e.message}")
      raise ClientError, "Client error: #{e.message}"
    rescue => e
      Rails.logger.error("OpenAI Unexpected Error: #{e.message}")
      raise Error, "Unexpected error: #{e.message}"
    end
  end

  def default_model
    ENV.fetch('OPENAI_DEFAULT_MODEL', 'gpt-4-turbo')
  end

  def default_temperature
    ENV.fetch('OPENAI_DEFAULT_TEMPERATURE', 0.2).to_f
  end
end
```

## 5. Service Layer Architecture

### Agent Service Base Class

```ruby
# app/services/agent_service.rb
class AgentService
  attr_reader :session_id, :user_query, :context, :openai_client

  def initialize(session_id, user_query, context = {})
    @session_id = session_id
    @user_query = user_query
    @context = context
    @openai_client = OpenaiClient.new
  end

  def call
    # Template method to be implemented by subclasses
    raise NotImplementedError
  end

  private

  def log_trace(agent_type, input_data, output_data)
    AgentTrace.create!(
      message_id: context[:message_id],
      agent_type: agent_type,
      input_data: input_data,
      output_data: output_data
    )
  end

  def default_model
    ENV.fetch('OPENAI_DEFAULT_MODEL', 'gpt-4-turbo')
  end

  def default_temperature
    ENV.fetch('OPENAI_DEFAULT_TEMPERATURE', 0.2).to_f
  end
end
```

### Triage Agent Implementation

```ruby
# app/services/triage_agent_service.rb
class TriageAgentService < AgentService
  AGENT_TYPES = %w[knowledge research support_ticket].freeze

  def call
    response = openai_client.create_response(
      messages: build_messages,
      temperature: 0.0,
      model: default_model
    )

    agent_type = parse_agent_type(response)
    log_trace('triage', { query: user_query }, { agent_type: agent_type })

    agent_type
  end

  private

  def build_messages
    [
      { role: "system", content: triage_system_prompt },
      { role: "user", content: user_query }
    ]
  end

  def triage_system_prompt
    <<~PROMPT
      You are a triage agent for a customer support system. Your job is to analyze the user's query and determine which specialized agent should handle it.

      Available agents:
      - knowledge: For questions about products, services, internal information, FAQs, or documentation.
      - research: For queries that require current external information, news, or data from the web.
      - support_ticket: For requests to create a support ticket, report an issue, or get help with a specific problem.

      Respond ONLY with one of these exact agent types: knowledge, research, or support_ticket.
      Do not provide any explanation or additional text in your response.
    PROMPT
  end

  def parse_agent_type(response)
    content = response.dig('choices', 0, 'message', 'content').to_s.strip.downcase
    
    case content
    when /knowledge/i
      'knowledge'
    when /research/i
      'research'
    when /support.*ticket|ticket|support/i
      'support_ticket'
    else
      # Default to knowledge if unclear
      Rails.logger.warn("Unclear triage result: '#{content}', defaulting to 'knowledge'")
      'knowledge'
    end
  end
end
```

### Agent Orchestrator Service

```ruby
# app/services/agent_orchestrator_service.rb
class AgentOrchestratorService
  attr_reader :session_id, :user_query, :context

  def initialize(session_id, user_query, context = {})
    @session_id = session_id
    @user_query = user_query
    @context = context
  end

  def call
    # Store the user message
    message = store_user_message

    # Add message_id to context for tracing
    context_with_message = context.merge(message_id: message.id)

    # Handle confirmation responses (from previous interactions)
    if context[:confirmed].present?
      return handle_confirmation(message, context_with_message)
    end

    # Determine which agent should handle this query
    agent_type = determine_agent_type(context_with_message)

    # Call the appropriate agent service
    response = call_agent_service(agent_type, context_with_message)

    # Handle confirmation requests (specifically for ticket creation)
    if response.is_a?(Hash) && response[:requires_confirmation]
      store_assistant_message(response[:content], requires_confirmation: true)
      return response[:content]
    end

    # Store the assistant's response
    store_assistant_message(response)

    response
  end

  private

  def determine_agent_type(context)
    # If the agent type is specified in the context, use it
    return context[:agent_type] if context[:agent_type].present?

    # Otherwise, use the triage agent to determine the appropriate agent
    TriageAgentService.new(session_id, user_query, context).call
  end

  def call_agent_service(agent_type, context)
    case agent_type
    when 'knowledge'
      KnowledgeAgentService.new(session_id, user_query, context).call
    when 'research'
      ResearchAgentService.new(session_id, user_query, context).call
    when 'support_ticket'
      SupportTicketAgentService.new(session_id, user_query, context).call
    else
      error_message = "Unknown agent type: #{agent_type}"
      Rails.logger.error(error_message)
      "I'm sorry, but I encountered an error processing your request. Please try again."
    end
  end
  
  # Additional helper methods...
end
```

## 6. Controller and View Implementation

### Controller

```ruby
# app/controllers/support_sessions_controller.rb
class SupportSessionsController < ApplicationController
  before_action :set_support_session, only: [:show, :update, :confirm]

  def index
    @support_sessions = SupportSession.order(created_at: :desc).limit(10)
  end

  def show
    @messages = @support_session.messages.order(created_at: :asc)
    @message = Message.new
  end

  def create
    @support_session = SupportSession.create!
    redirect_to @support_session
  end

  def update
    @message = Message.new(message_params)
    
    # Process the message with our orchestrator
    respond_to do |format|
      format.turbo_stream do
        # First add the user message to the stream
        render turbo_stream: turbo_stream.append(
          "messages",
          partial: "messages/message",
          locals: { message: { content: @message.content, role: 'user' } }
        )
        
        # Then process and add the assistant's response
        @response = AgentOrchestratorService.new(
          @support_session.id, 
          @message.content
        ).call
        
        # Get the latest assistant message with all metadata
        @assistant_message = @support_session.messages.where(role: 'assistant').last
        
        render turbo_stream: turbo_stream.append(
          "messages",
          partial: "messages/message",
          locals: { message: @assistant_message }
        )
      end
      
      format.html { redirect_to @support_session }
    end
  end

  def confirm
    # Handle confirmation for actions that need user approval
    confirmation = params[:confirmed] == 'true'
    
    respond_to do |format|
      format.turbo_stream do
        @response = AgentOrchestratorService.new(
          @support_session.id, 
          "Confirmation: #{confirmation ? 'Yes' : 'No'}", 
          { confirmed: confirmation }
        ).call
        
        # Get the latest assistant message
        @assistant_message = @support_session.messages.where(role: 'assistant').last
        
        render turbo_stream: turbo_stream.append(
          "messages",
          partial: "messages/message",
          locals: { message: @assistant_message }
        )
      end
      
      format.html { redirect_to @support_session }
    end
  end

  private

  def set_support_session
    @support_session = SupportSession.find(params[:id])
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
```

## 7. Testing Strategy

### RSpec Configuration

```ruby
# .rspec
--require spec_helper
--format documentation
--color
```

```ruby
# spec/rails_helper.rb
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/vcr_cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!
  
  # Filter out sensitive data
  config.filter_sensitive_data('<OPENAI_API_KEY>') { ENV['OPENAI_API_KEY'] }
  
  # Allow localhost requests to pass through (for system tests)
  config.ignore_localhost = true
end
```

### Example Service Tests

```ruby
# spec/services/triage_agent_service_spec.rb
require 'rails_helper'

RSpec.describe TriageAgentService do
  let(:session_id) { 1 }
  let(:context) { { message_id: 1 } }
  let(:openai_client) { instance_double("OpenaiClient") }
  
  before do
    allow(OpenaiClient).to receive(:new).and_return(openai_client)
    allow(AgentTrace).to receive(:create!)
  end
  
  describe '#call' do
    context 'when query is about product information' do
      let(:user_query) { "What are the features of your product?" }
      let(:response) { { 'choices' => [{ 'message' => { 'content' => 'knowledge' } }] } }
      
      before do
        allow(openai_client).to receive(:create_response).and_return(response)
      end
      
      it 'returns knowledge agent type' do
        service = described_class.new(session_id, user_query, context)
        expect(service.call).to eq('knowledge')
      end
    end
    
    # Additional test cases...
  end
end
```

## 8. Deployment Guidelines

### Docker Setup

```dockerfile
# Dockerfile.production
FROM ruby:3.2-slim

# Install dependencies
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    libpq-dev \
    nodejs \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without 'development test' \
    && bundle install --jobs 20 --retry 5

# Copy application code
COPY . .

# Precompile assets
RUN bundle exec rails assets:precompile RAILS_ENV=production

# Add a script to be executed every time the container starts
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# Expose port
EXPOSE 3000

# Start the main process
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
```

## 9. Security Considerations

### API Key Management

```ruby
# config/credentials.yml.enc (encrypted, managed via Rails credentials)
openai:
  api_key: sk_...
  organization_id: org_...

help_desk:
  api_key: hd_...
  url: https://example.com/help-desk
```

### Rate Limiting

```ruby
# config/initializers/rack_attack.rb
class Rack::Attack
  ### Configure Cache ###
  Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(url: ENV['REDIS_URL'])

  ### Throttle high volumes of requests by IP address
  throttle('req/ip', limit: 300, period: 5.minutes) do |req|
    req.ip unless req.path.start_with?('/assets')
  end

  ### Throttle POST requests to /support_sessions/:id by IP
  throttle('messages/ip', limit: 10, period: 1.minute) do |req|
    if req.path =~ /\/support_sessions\/\d+/ && req.post?
      req.ip
    end
  end
  
  # Additional throttling rules...
end
```

## 10. Extensibility Framework

### Adding New Agent Types

To add a new specialized agent:

1. Create a new service class inheriting from `AgentService`
2. Update the `TriageAgentService` to recognize and route to the new agent
3. Update the `AgentOrchestratorService` to handle the new agent

### Implementation Roadmap

1. **Phase 1: Core Functionality Enhancements**
   - Authentication and authorization
   - User profile management
   - Conversation history management
   - Basic analytics

2. **Phase 2: Integration Expansion**
   - CRM integration
   - Ticketing system integration
   - API for external access
   - Webhook support

3. **Phase 3: Advanced Features**
   - Personalization engine
   - Learning and improvement capabilities
   - Multi-language support
   - Voice interface

This technical specification provides a solid foundation for building a robust, scalable, and extensible Customer Support & Research Assistant MVP that demonstrates the capabilities of AI agents in a Ruby on Rails environment.
