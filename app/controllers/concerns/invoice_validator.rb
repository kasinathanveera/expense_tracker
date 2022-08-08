module InvoiceValidator
  require 'rest-client'
  
  def store_invoice_validations(json)
    Invoice.create(invoice_number: invoice_number, biller: json['biller name'])
  end

  def invoice_validator_response(invoice_number)
    requets_body = '{"invoice_id":'"#{invoice_number}"'}'
    invoice_repsone = RestClient.post('https://my.api.mockaroo.com/invoices.json?key=b490bb80',
                                      requets_body)
    JSON.parse(invoice_repsone.body)
  end
end
