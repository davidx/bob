require 'slack'

require "jenkins_api_client"

@jenkins_client = JenkinsApi::Client.new(
    :server_url => 'http://10.0.1.7:8080/',
    :username => ENV['JENKINS_USER'],
    :password => ENV['JENKINS_PASS'])

Slack.configure do |config|
  config.token = ENV['SLACK_API_TOKEN']
end
bot_user='<@U2HQV5S56>'
@client = Slack::RealTime::Client.new

@client.on :hello do
  puts 'Successfully connected.'
end

def respond(channel, message)
  @client.message channel: channel, text: message
end

@client.on :message do |data|
  message_content = data['text']
  case message_content
    when /#{bot_user}/ then
      command = message_content.slice(13, message_content.length) || ""
      command.strip!
      case command
        when "jenkins jobs" then
          respond data['channel'], @jenkins_client.job.list_all.join("\n")
        when /^build/ then
          build_target = command.slice(5, command.length)
          build_target.strip!
          p " have build target: #{build_target}"
          case build_target
            when /^jenkins(.*)/ then
              job_name = build_target.split(/:/).pop
              p "got jenkins build_target"
              begin
                code = @jenkins_client.job.build(job_name)
                print "code: #{code.inspect}"
                if code.to_i == 201
                  respond data['channel'], "Great, code: #{code}. Kicked off build of job #{job_name}"
                else
                  respond data['channel'], "Err: #{code} on build of job #{job_name}"
                end
              rescue JenkinsApi::Exceptions::NotFound => e
                respond data['channel'], "Oops, can't find that job #{job_name}"
              end
            when /^travis/ then
               respond data['channel'], "Great, code: #{code}. Kicked off build of job #{job_name}"
            else
              respond data['channel'], "usage  @bob build jenkins:jobname"
          end

        when /^thumbs/ then
          test_pr = message_content.gsub(/thumbs/, '').strip
          respond data['channel'], "Great, running thumbs"
      end
  end
end

@client.start!

