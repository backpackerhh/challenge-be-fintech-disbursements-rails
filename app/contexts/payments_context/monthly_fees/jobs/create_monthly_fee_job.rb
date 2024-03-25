# frozen_string_literal: true

module PaymentsContext
  module MonthlyFees
    module Jobs
      class CreateMonthlyFeeJob < SharedContext::Jobs::BaseJob
        sidekiq_options queue: "monthly_fees"

        attr_reader :find_merchant_service, :calculate_monthly_order_commissions_amount_service

        def initialize(
          find_merchant_service: Merchants::Services::FindMerchantService.new,
          calculate_monthly_order_commissions_amount_service:
            OrderCommissions::Services::CalculateMonthlyOrderCommissionsAmountService.new
        )
          super()
          @find_merchant_service = find_merchant_service
          @calculate_monthly_order_commissions_amount_service = calculate_monthly_order_commissions_amount_service
        end

        def perform(merchant_id, start_date)
          merchant = find_merchant_service.find(merchant_id)

          previous_month_date = Date.parse(start_date).prev_month
          formatted_previous_month = previous_month_date.strftime("%Y-%m")
          commissions_amount = calculate_monthly_order_commissions_amount_service.calculate(
            merchant_id,
            previous_month_date
          )

          if merchant.monthly_fee_applicable?(commissions_amount, previous_month_date)
            UseCases::CreateMonthlyFeeUseCase.new.create(
              merchant_id:,
              commissions_amount:,
              amount: merchant.minimum_monthly_fee.value - commissions_amount,
              month: formatted_previous_month
            )

            logger.info("Monthly fee for merchant #{merchant_id} successfully created (#{formatted_previous_month})")
          else
            logger.info("No monthly fee created for merchant #{merchant_id} (#{formatted_previous_month})")
          end
        end
      end
    end
  end
end
