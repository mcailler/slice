@clearErrorAndWarning = (parent, data) ->
  container = $(parent).closest('[data-object~="variable-container"]')
  container.removeClass('variable-errors variable-warnings')

@setError = (parent, data) ->
  clearErrorAndWarning(parent, data)
  container = $(parent).closest('[data-object~="variable-container"]')
  container.addClass('variable-errors')

@setWarning = (parent, data) ->
  clearErrorAndWarning(parent, data)
  container = $(parent).closest('[data-object~="variable-container"]')
  container.addClass('variable-warnings')

@setSuccess = (parent, data) ->
  clearErrorAndWarning(parent, data)
  # container = $(parent).closest('[data-object~="variable-container"]')

@clearClassStyles = (target_name) ->
  $("##{target_name}_month").parent().removeClass('has-warning has-error')
  $("##{target_name}_day").parent().removeClass('has-warning has-error')
  $("##{target_name}_year").parent().removeClass('has-warning has-error')
  $("##{target_name}_hour").parent().removeClass('has-warning has-error')
  $("##{target_name}_minutes").parent().removeClass('has-warning has-error')
  $("##{target_name}_seconds").parent().removeClass('has-warning has-error')
  $("##{target_name}").parent().removeClass('has-warning has-error')
  $("##{target_name}_alert_box")
    .removeClass('bs-callout-warning bs-callout-danger')

@setDefaultClassStyles = (target_name, data) ->
  $("##{target_name}_alert_box").show()
  $("##{target_name}_message").html(data['message'])
  $("##{target_name}_formatted_value").html(data['formatted_value'])

@setValidationProperty = (parent, data) ->
  $(parent).data('status', data['status'])
  container = $(parent).closest('[data-object~="variable-container"]')
  if data['status'] in ['invalid', 'out_of_range']
    setError(parent, data)
  else if data['status'] == 'blank' and container.data('required') == 'required'
    setError(parent, data)
  else if (data['status'] == 'blank' and container.data('required') == 'recommended') or (data['status'] == 'in_hard_range')
    setWarning(parent, data)
  else
    setSuccess(parent, data)

@setGenericValidityClass = (parent, data) ->
  target_name = parent.data("target-name")
  clearClassStyles(target_name)
  setDefaultClassStyles(target_name, data)

  setValidationProperty(parent, data)

  if data['status'] == 'invalid' or data['status'] == 'out_of_range'
    $("##{target_name}").parent().addClass('has-error')
    $("##{target_name}_alert_box").addClass('bs-callout-danger')
  if data['status'] == 'in_hard_range'
    $("##{target_name}").parent().addClass('has-warning')
    $("##{target_name}_alert_box").addClass('bs-callout-warning')
  if data['status'] == 'blank' or data['status'] == 'in_soft_range'
    $("##{target_name}_alert_box").hide() if data['message'] == ''

@setDateValidityClass = (parent, data) ->
  target_name = parent.data("target-name")
  clearClassStyles(target_name)
  setDefaultClassStyles(target_name, data)

  setValidationProperty(parent, data)

  if data['status'] == 'invalid' or data['status'] == 'out_of_range'
    $("##{target_name}_alert_box").addClass('bs-callout-danger')
    $("##{target_name}_year").parent().addClass('has-error')
    $("##{target_name}_month").parent().addClass('has-error')
    $("##{target_name}_day").parent().addClass('has-error')
  if data['status'] == 'in_hard_range'
    $("##{target_name}_year").parent().addClass('has-warning')
    $("##{target_name}_month").parent().addClass('has-warning')
    $("##{target_name}_day").parent().addClass('has-warning')
    $("##{target_name}_alert_box").addClass('bs-callout-warning')
  if data['status'] == 'blank' or data['status'] == 'in_soft_range'
    $("##{target_name}_alert_box").show()

@setTimeValidityClass = (parent, data) ->
  target_name = parent.data("target-name")
  clearClassStyles(target_name)
  setDefaultClassStyles(target_name, data)

  setValidationProperty(parent, data)

  if data['status'] == 'invalid' or data['status'] == 'out_of_range'
    $("##{target_name}_alert_box").addClass('bs-callout-danger')
    $("##{target_name}_hour").parent().addClass('has-error')
    $("##{target_name}_minutes").parent().addClass('has-error')
    $("##{target_name}_seconds").parent().addClass('has-error')
  if data['status'] == 'in_hard_range'
    $("##{target_name}_hour").parent().addClass('has-warning')
    $("##{target_name}_minutes").parent().addClass('has-warning')
    $("##{target_name}_seconds").parent().addClass('has-warning')
    $("##{target_name}_alert_box").addClass('bs-callout-warning')
  if data['status'] == 'blank' or data['status'] == 'in_soft_range'
    $("##{target_name}_alert_box").show()

@setVariableValidityClass = (parent, data) ->
  if $(parent).data('components') == 'date'
    setDateValidityClass(parent, data)
  else if $(parent).data('components') == 'time'
    setTimeValidityClass(parent, data)
  else
    setGenericValidityClass(parent, data)
  checkRequiredAndInvalidFormat()

@valueToJSON = (parent) ->
  switch $(parent).data('components')
    when 'date'
      value = {}
      value["month"]  = $("##{$(parent).data('target-name')}_month").val()
      value["day"]    = $("##{$(parent).data('target-name')}_day").val()
      value["year"]   = $("##{$(parent).data('target-name')}_year").val()
    when 'time'
      value = {}
      value["hour"]  = $("##{$(parent).data('target-name')}_hour").val()
      value["minutes"]    = $("##{$(parent).data('target-name')}_minutes").val()
      value["seconds"]   = $("##{$(parent).data('target-name')}_seconds").val()
    when 'checkbox'
      value = []
      children = $(parent).find('input:checked')
      $.each(children, (index, child) ->
        value.push($(child).val())
      )
    when 'radio'
      value = ''
      children = $(parent).find('input:checked')
      $.each(children, (index, child) ->
        value = $(child).val()
      )
    else
      value = $("##{$(parent).data('target-name')}").val()
  value

@validateElement = (element) ->
  parent = $(element).closest('[data-object~="validate"]')

  changes = {}
  changes["project_id"] = $(parent).data('project-id')
  changes["variable_id"] = $(parent).data('variable-id')
  changes["value"] = valueToJSON(parent)

  url = root_url + 'validate/variable'

  $.ajax(
    url: url
    type: 'POST'
    dataType: 'json'
    data: changes
  ).done( (data) ->
    setVariableValidityClass(parent, data)
  ).fail( (jqXHR, textStatus, errorThrown) ->
    console.log("FAIL: #{textStatus} #{errorThrown}")
  )

@checkRequiredAndInvalidFormat = () ->
  fields = $('[data-required~="required"]:visible').find('[data-status]:visible').filter( () ->
    $(this).data('status') == "blank" || $(this).data('status') == "invalid"
  )

  out_of_range_fields = $('[data-status]:visible').filter( () ->
    $(this).data('status') == "out_of_range"
  )

  field_count = fields.length + out_of_range_fields.length

  if field_count > 0
    $("#validation-messages").html("#{field_count} field#{if field_count == 1 then ' is' else 's are'} invalid, missing, or out of range")
  else
    $("#validation-messages").html("")

$(document)
  .on('blur', '[data-object~="validate"] input, [data-object~="validate"] textarea', () ->
    validateElement($(this))
  )
  .on('change', '[data-object~="validate"] .checkbox input:checkbox, [data-object~="validate"] .radio input:radio', () ->
    validateElement($(this))
  )
