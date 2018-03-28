require 'http'

class Order < ApplicationRecord

  # create order on COS
    # POST {mid}/orders => status: "open"
    # forEach lineItem GET /items
      # POST {mid}/orders => bulkLineItems
    # POST {mid}/orders => total: $xxx, tax: $xxx
  # find or create customer on COS
    # GET {mid}/customers/{customer_uuid}
      # if not, POST {mid}/customers/ => {name, address, city, zip}
  # POST customer onto order {mid}/orders/{oid}/ => {customers: [{customerObject}]}

  def self.create_order_on_COS(params)
    access_token = Rails.application.secrets.clover_access_token
    mId = Rails.application.secrets.clover_mid
    debugger
    base_url = "https://sandbox.dev.clover.com/v3/merchants/#{mId}/"
    res = HTTP.auth("Bearer #{access_token}").post(base_url + "orders/",
      body: ({state: "open"}).to_json)
    orderRes = res.parse
    order_id = orderRes['id']

    addLineItems = {
      "items": params["lineItems"]
    }

    res2 = HTTP.auth("Bearer #{access_token}").post(base_url + "orders/#{order_id}/bulk_line_items",
      body: addLineItems.to_json)

    orderRes["lineItems"] = {
      "elements": res2.parse
    }


    find_or_create_customer_on_COS(params, order_id)

    send_notification(orderRes)

    return orderRes
  end

  def self.send_notification(order)
    app_secret = Rails.application.secrets.clover_app_secret
    mId = Rails.application.secrets.clover_mid
    aId = Rails.application.secrets.clover_app_id
    base_url = "https://sandbox.dev.clover.com/v3/apps/#{aId}/merchants/#{mId}/"

    res = HTTP.auth("Bearer #{app_secret}").post(base_url + "notifications/",
      body: ({
        "event": "online_order",
        "data": ({order: order}).to_json
      }).to_json
    )

    res.parse
  end

  def self.find_or_create_customer_on_COS(params, order_id)
      access_token = '317FF8D0177BF761AE39CA5622AB00A4'
      mId = 'EJE2ZH35JJAG2'
      base_url = "https://sandbox.dev.clover.com/v3/merchants/#{mId}/"
      customer = params['customer']

      customer_uuid = params['customer']['uuid']
      if(customer_uuid.empty?)
        res = HTTP.auth("Bearer #{access_token}").post(base_url + "customers/",
          body: customer.to_json)
        customer_uuid = res.parse['id']
      end

      res2 = HTTP.auth("Bearer #{access_token}").post(base_url + "orders/" + order_id,
        body: ({"customers": [{"id": customer_uuid}]}).to_json)

      # order info
      res2.parse
  end
end
