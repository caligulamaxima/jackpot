module Jackpot
  class Customer < ActiveRecord::Base
    belongs_to      :subscription
    has_many        :payments, :through => :subscription  
    attr_protected  :credit_card_number
    attr_protected  :credit_card_expiry_year
    attr_protected  :credit_card_expiry_month
    attr_protected  :credit_card_token

    scope :due_in , lambda { |number_of_days| where("good_until <= ?", 
                                                    number_of_days.days.from_now) }

    scope :overdue , where("good_until < ? ", Date.today)


    attr_accessor   :credit_card_verification_value

    def pay_subscription
      if credit_card_token   
        if subscription.present? && subscription.charge(self)
          update_attribute(:good_until, Date.today + 1.month)
        end 
      else 
        raise Jackpot::Errors::CustomerHasNoCardSaved.new
      end 
    end 
    

    def update_credit_card(card)  
      raise Errors::CardIsInvalid unless card.valid? 
      write_attribute  :credit_card_number            ,  card.masquerade_number
      write_attribute  :credit_card_expiry_month      ,  card.month
      write_attribute  :credit_card_expiry_year       ,  card.year

      # This should never be recorded 
      self.credit_card_verification_value = card.verification_value
      stored_card_response = Jackpot::Base.gateway.store(card)
      write_attribute :credit_card_token , stored_card_response.params["customer_vault_id"]

      save
    end 

    def expiration_date
      "#{credit_card_expiry_month}/#{credit_card_expiry_year}"
    end 

  end
end
