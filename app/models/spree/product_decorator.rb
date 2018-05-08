Spree::Product.class_eval do
    
    scope :avgrating, ->{ order(avg_rating: :desc).limit(5)}

  end