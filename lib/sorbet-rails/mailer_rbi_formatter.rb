# typed: strict
require('parlour')
require('sorbet-rails/sorbet_utils.rb')

class SorbetRails::MailerRbiFormatter
  extend T::Sig

  sig { params(mailer_class: T.class_of(ActionMailer::Base)).void }
  def initialize(mailer_class)
    @mailer_class = T.let(mailer_class, T.class_of(ActionMailer::Base))
    @parlour = T.let(Parlour::RbiGenerator.new, Parlour::RbiGenerator)
  end

  sig {returns(String)}
  def generate_rbi
    puts "-- Generate sigs for mailer #{@mailer_class.name} --"

    @parlour.root.add_comments([
      "This is an autogenerated file for Rails' mailers.",
      'Please rerun bundle exec rake rails_rbi:mailers to regenerate.'
    ])

    @parlour.root.create_class(@mailer_class.name) do |mailer_rbi|
      @mailer_class.action_methods.to_a.sort.each do |mailer_method|
        method_def = @mailer_class.instance_method(mailer_method)
        parameters = SorbetRails::SorbetUtils.parameters_from_method_def(method_def)
        mailer_rbi.create_method(
          mailer_method,
          parameters: parameters,
          return_type: 'ActionMailer::MessageDelivery',
          class_method: true,
        )
      end
    end

    @parlour.rbi
  end
end
