# frozen_string_literal: true

class CustomiseOrderController < CheckoutController
  def customise_order
    render "customise_order", locals: {
      order: current_order,
      customise_order: CustomiseOrder.new(cart: current_cart),
      extras_list: current_cart.extras_list,
    }
  end

  def save_order_customisation
    args = { cart: current_cart }.merge(params[:customise_order])
    return if cart_expired?(args)
    customise_order = CustomiseOrder.new(args)
    customise_order.save ? successful_order_customisation : failed_order_customisation(customise_order)
  end

private

  def successful_order_customisation
    redirect_to next_step
  end

  def next_step
    if current_webstore_customer.guest?
      authentication_path
    else
      delivery_options_path
    end
  end

  def failed_order_customisation(customise_order)
    flash[:alert] = t("oops") << t("colon") <<
                    customise_order.errors.values.join(", ").downcase

    render "customise_order", locals: {
      order: current_order,
      customise_order: customise_order,
      extras_list: current_cart.extras_list,
    }
  end
end
