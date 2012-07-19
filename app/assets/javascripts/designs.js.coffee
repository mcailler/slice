# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/


# This function updates all variables starting with lowest one and progressing up in visibility.
# After hiding or showing all the variables, it updates the scroll-spy to correct any offsets that may
# have been introduced
@updateAllVariables = () ->
  variableContainers = $('[data-object~="variable-container"]')
  # dmsg("Updating #{variableContainers.length} Variables")
  # $(variableContainers.get().reverse()).each( (index, variableContainer) ->
  variableContainers.each( (index, variableContainer) ->
    updateVariableContainer(variableContainer)
  )
  $('[data-spy="scroll"]').each( () ->
    $spy = $(this).scrollspy('refresh')
  )
  false


# This function updates an individual variables container to show or be hidden based on what variable keys it depends on.
# Show if none of the values evaluate to false [1,1,1,1] or [], but not [1,0,1,1] or [0]
@updateVariableContainer = (element) ->
  # dmsg("Updating #{$(element).attr('id')}")
  values_hash = $(element).data('values-hash') || []
  truth_table = []
  $.each(values_hash, (index, condition_hash) ->
    result = checkCondition(condition_hash)
    truth_table.push(result)
  )
  # dmsg truth_table
  if 0 in truth_table
    $(element).hide()
    dmsg("Hiding #{$(element).attr('id')}")
  else
    $(element).show()
    dmsg("Showing #{$(element).attr('id')}")
  true

# Check if dom element evaluates to true for any of the given values
# If so, return 1, else return 0
@checkCondition = (condition_hash) ->
  element = $(condition_hash['location'])
  # Values that make it be shown
  condition_values = condition_hash['values']
  return 1 if condition_values.length == 0
  return 0 if element.is(':hidden')
  # Elements that might be the values.
  selected_values = []
  $(element).find('[data-object~="condition"]').each( (index, el) ->
    if ($(el).is(':checkbox, :radio') and $(el).is(':checked')) or not $(el).is(':checkbox, :radio')
      selected_values.push($(el).val())
  )
  # dmsg "Condition values: #{condition_values} <=> Selected Values: #{selected_values}"
  if intersection(condition_values, selected_values).length > 0
    1
  else
    0


@retrieveVariable = (position) ->
  variable_id = $('#design_option_tokens_' + position + '_variable_id').val()
  if variable_id
    $.get(root_url + 'variables/' + variable_id, 'position=' + position, null, "script")
  false

@intersection = (a, b) ->
  [a, b] = [b, a] if a.length > b.length
  value for value in a when value in b


# TODO REMOVE BELOW
@dmsg = (message) ->
  # $('#error_log').prepend('<li>' + message + '</li>')
  false


# @toggleCondition = (element) ->
#   dmsg("Checking Locked #{$(element).attr('id')} Locked: '#{$(element).data('locked')}'")
#   if $(element).data('locked') == 1
#     dmsg("Skipping #{$(element).attr('id')}")
#     return false
#   $(element).data('locked', 1)
#   dmsg("Locking #{$(element).attr('id')}")
#   window.indentcount = window.indentcount + 1
#   conditional_variable_id = $(element).data('condition-target')
#   selector = '[data-condition-parent~="' + conditional_variable_id + '"]'
#   $(selector).each( (index, el) ->
#     if $(element).is(':hidden')
#       $(el).hide()
#       dmsg("Hiding #{$(el).attr('id')}")
#     else if $(element).is(':checkbox, :radio')
#       values = []
#       $.each($("input[name='" + $(element).attr('name') + "']:checked"), () ->
#         values.push($(this).val())
#       )
#       if intersection(values, String($(el).data('condition-value')).split(',')).length > 0
#         $(el).show()
#         dmsg("Showing #{$(el).attr('id')}")
#       else
#         $(el).hide()
#         dmsg("Hiding #{$(el).attr('id')}")
#     else
#       if String($(element).val()) in String($(el).data('condition-value')).split(',')
#         $(el).show()
#         dmsg("Showing #{$(el).attr('id')}")
#       else
#         $(el).hide()
#         dmsg("Hiding #{$(el).attr('id')}")
#     $(el).find('[data-object~="condition"]').change()
#   )
#   window.indentcount = window.indentcount - 1
#   dmsg("Unlocking #{$(element).attr('id')}")
#   dmsg("")
#   $(element).data('locked', 0)
#   false
# TODO Remove Above

jQuery ->

  $('#add_more_variables').on('click', () ->
    $.post(root_url + 'designs/add_variable', $("form").serialize() + "&_method=post", null, "script")
    false
  )

  $('#add_more_sections').on('click', () ->
    $.post(root_url + 'designs/add_section', $("form").serialize() + "&_method=post", null, "script")
    false
  )

  $('#add_more_variables_top').on('click', () ->
    $.post(root_url + 'designs/add_variable', $("form").serialize() + "&location=top&_method=post", null, "script")
    false
  )

  $('#add_more_sections_top').on('click', () ->
    $.post(root_url + 'designs/add_section', $("form").serialize() + "&location=top&_method=post", null, "script")
    false
  )

  $('#variables[data-object~="sortable"]').sortable( placeholder: "well alert alert-block" )

  $(document)
    .on('change', '[data-object~="condition"]', () ->
      # toggleCondition($(this))
      updateAllVariables()
    )
    .on('click', '[data-object~="expand-details"]', () ->
      $('[data-object~="' + $(this).data('selector') + '"]').hide()
      $($(this).data('target')).show()
      false
    )


  # $('[data-object~="variable-load"]').change( () ->
  #   retrieveVariable($(this).data('position'))
  #   false
  # )

