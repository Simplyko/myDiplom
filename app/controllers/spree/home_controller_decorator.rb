Spree::HomeController.class_eval do

       layout 'spree/layouts/spree_application'
      def index
            @avg_rating_products = Spree::Product.avgrating
      end
end
