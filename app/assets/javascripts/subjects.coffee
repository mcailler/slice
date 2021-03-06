@subjectsReady = () ->
  $("#subject-search").each( () ->
    $this = $(this)
    $this.typeahead(
      remote: root_url + "projects/#{$this.data('project-slug')}/subjects/search?q=%QUERY"
      template: '<p><span class="label label-{{status_class}}">{{status}}</span> <strong>{{subject_code}}</strong> {{acrostic}}</p>'
      engine: Hogan
    )
  )

$(document)
  .on('change', '#subject_project_id', () ->
    $.post(root_url + 'projects/' + $("#subject_project_id").val() + '/sites/selection', 'subject_code=' + $("#subject_subject_code").val() + '&select=1', null, "script")
    false
  )
