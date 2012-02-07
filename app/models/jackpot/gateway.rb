module Jackpot 

  # Small adapter for Active Merchant gateways Jackpot supports
  class Gateway

    def initialize(gateway)
      @gateway = gateway
    end 

    def store(card)
      @gateway.store card.adapted_card
    end 

    def authorize(amount, card)
      @gateway.authorize(amount, card.adapted_card)
    end 

    def capture(amount, authorization_code)
      @gateway.capture(amount, authorization_code)
    end 

  end 

end 