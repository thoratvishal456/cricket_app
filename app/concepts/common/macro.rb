# frozen_string_literal: true

module Common
  module Macro
    def self.RecordNotFound(model_name, fail_fast: true)
      task = ->((ctx, flow_options), _) do
        ctx[:error] = {
          msg: I18n.t("errors.record_not_found", model_name: model_name),
          code: :unprocessable_entity
        }

        return Trailblazer::Operation::Railway.fail!, [ctx, flow_options]
      end

      { task: task, id: :record_not_found, fail_fast: fail_fast }
    end

    def self.SomethingWentWrong(fail_fast: true)
      task = ->((ctx, flow_options), _) do
        ctx[:error] = {
          msg: I18n.t("errors.something_went_wrong"),
          code: :internal_server_error
        }

        return Trailblazer::Operation::Railway.fail!, [ctx, flow_options]
      end

      { task: task, id: :something_went_wrong, fail_fast: fail_fast }
    end

    def self.ContractValidationFailed(fail_fast: true)
      task = ->((ctx, flow_options), _) do
        contract = ctx["contract.default"]
        errors = contract.errors.full_messages.presence || contract.model.errors.full_messages
        ctx[:error] = {
          msg: errors[0],
          code: :unprocessable_entity
        }

        return Trailblazer::Operation::Railway.fail!, [ctx, flow_options]
      end

      { task: task, id: :invalid_params, fail_fast: fail_fast }
    end

    # This macro assumes that any other status than success from event is failure
    # rollback all the transaction
    class InTransaction
      def self.call((ctx, flow_options), *, &block)
        result =
          begin
            ActiveRecord::Base.transaction do
              last_event, (ctx, flow_options) = yield
              unless last_event.to_h[:semantic] == :success
                raise AcitveRecord::Rollback
              end
              true
            end
          rescue
            ctx[:error] = {
              msg: I18n.t("transaction.error")
            }
            false
          end

        signal = result ? Trailblazer::Operation::Railway.pass! : Trailblazer::Operation::Railway.fail!
        [ signal, [ctx, flow_options] ]
      end
    end
  end
end
