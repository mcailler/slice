# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

@buildDesignOption = (element) ->
  design_option = {}
  design_option.position = element.data('position')
  return design_option

@buildSectionFormData = () ->
  formData = new FormData()
  formData.append("section[name]", $("#section_name").val())
  formData.append("section[description]", $("#section_description").val())
  formData.append("section[image]", $("#section_image").prop("files")[0])
  formData.append("section[remove_image]", $("#section_remove_image").is(":checked"))
  formData.append("section[sub_section]", $("#section_sub_section").is(":checked"))
  formData.append("design_option[position]", $("#design_option_position").val())
  formData.append("design_option[branching_logic]", $("#design_option_branching_logic").val()) unless $("#design_option_branching_logic").val() == undefined
  return formData

@hideInteractiveDesignModal = () ->
  $('#interactive_design_modal').modal('hide')

@showInteractiveDesignModal = () ->
  $('#interactive_design_modal').modal('show')

$(document)
  .on('click', '[data-object~="new-section-popup"]', () ->
    project_id = $("#project_id").val()
    design_id = $('#design_id').val()
    changes = {}
    changes.design_option = buildDesignOption($(this))
    $.get("#{root_url}projects/#{project_id}/designs/#{design_id}/design_options/new_section", changes, null, "script")
    false
  )
  .on('click', '[data-object~="new-variable-popup"]', () ->
    project_id = $("#project_id").val()
    design_id = $('#design_id').val()
    changes = {}
    changes.design_option = buildDesignOption($(this))
    changes.variable = { variable_type: $(this).data('variable-type') }
    $.get("#{root_url}projects/#{project_id}/designs/#{design_id}/design_options/new_variable", changes, null, "script")
    false
  )
  .on('click', '[data-object~="new-existing-variable-popup"]', () ->
    project_id = $("#project_id").val()
    design_id = $('#design_id').val()
    changes = {}
    changes.design_option = buildDesignOption($(this))
    $.get("#{root_url}projects/#{project_id}/designs/#{design_id}/design_options/new_existing_variable", changes, null, "script")
    false
  )
  .on('click', '[data-object~="set-variable-domain"]', () ->
    project_id = $("#project_id").val()
    design_id = $('#design_id').val()
    design_option_id = $(this).data('design-option-id')
    changes = {}
    changes['_method'] = 'patch' if changes != null
    changes['variable'] = { domain_id: $($(this).data('target')).val() }
    $.post("#{root_url}projects/#{project_id}/designs/#{design_id}/design_options/#{design_option_id}", changes, null, "script")
  )
  .on('click', '[data-object~="submit-section-form-with-file"]', () ->
    $.ajax(
      url: $($(this).data('target')).attr('action')
      type: $(this).data('method')
      data: buildSectionFormData()
      cache: false
      contentType: false
      processData: false
    )
  )