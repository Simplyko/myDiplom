(function() {
  this.ShippingTotalManager = (function() {
    function ShippingTotalManager(input1) {
      this.input = input1;
      this.shippingMethods = this.input.shippingMethods;
      this.shipmentTotal = this.input.shipmentTotal;
      this.orderTotal = this.input.orderTotal;
      this.formatOptions = {
        symbol: this.shipmentTotal.data('currency'),
        decimal: this.shipmentTotal.attr('decimal-mark'),
        thousand: this.shipmentTotal.attr('thousands-separator'),
        precision: 2
      };
    }

    ShippingTotalManager.prototype.calculateShipmentTotal = function() {
      this.sum = 0;
      $.each($(this.shippingMethods).filter(':checked'), (function(_this) {
        return function(idx, shippingMethod) {
          return _this.sum += _this.parseCurrencyToFloat($(shippingMethod).data('cost'));
        };
      })(this));
      return this.readjustSummarySection(this.parseCurrencyToFloat(this.orderTotal.html()), this.sum, this.parseCurrencyToFloat(this.shipmentTotal.html()));
    };

    ShippingTotalManager.prototype.parseCurrencyToFloat = function(input) {
      return accounting.unformat(input, this.formatOptions.decimal);
    };

    ShippingTotalManager.prototype.readjustSummarySection = function(orderTotal, newShipmentTotal, oldShipmentTotal) {
      var newOrderTotal;
      newOrderTotal = orderTotal + (newShipmentTotal - oldShipmentTotal);
      this.shipmentTotal.html(accounting.formatMoney(newShipmentTotal, this.formatOptions));
      return this.orderTotal.html(accounting.formatMoney(newOrderTotal, this.formatOptions));
    };

    ShippingTotalManager.prototype.bindEvent = function() {
      return this.shippingMethods.change((function(_this) {
        return function() {
          return _this.calculateShipmentTotal();
        };
      })(this));
    };

    return ShippingTotalManager;

  })();

  Spree.ready(function($) {
    var input;
    input = {
      orderTotal: $('#summary-order-total'),
      shipmentTotal: $("[data-hook='shipping-total']"),
      shippingMethods: $("input[data-behavior='shipping-method-selector']")
    };
    return new ShippingTotalManager(input).bindEvent();
  });

}).call(this);
