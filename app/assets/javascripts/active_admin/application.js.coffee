# Initializers
$(document).on 'ready page:load', ->
  # jQuery datepickers (also evaluates dynamically added HTML)
  $(document).on 'focus', 'input.datepicker:not(.hasDatepicker)', ->
    $input = $(@)

    # Only applying datepicker to compatible browsers
    return if $input[0].type is 'date'

    defaults = dateFormat: 'yy-mm-dd'
    options = $input.data 'datepicker-options'
    $input.datepicker $.extend(defaults, options)

  # Clear Filters button
  $('.clear_filters_btn').click ->
    params = window.location.search.split('&')
    regex = /^(q\[|q%5B|q%5b|page|commit)/
    window.location.search = (param for param in params when not param.match(regex)).join('&')

  # Save Filters button
  $('.save_filters_btn').click ->
    ActiveAdmin.modal_dialog 'Save Filters And Apply', name: 'text', (inputs) =>
      form = $(@).parents('form')
      name_field = $('<input type="hidden" name="name" />').val(inputs.name)
      form.append(name_field)
      data = form.serialize()
      $.ajax
        url: $(@).data('url')
        method: 'POST'
        data: data
        success: (data) ->
          location.href = data.url
        complete: () ->
          name_field.remove()
    false

  $('.sidebar_section ul.saved_filters li a.delete').click ->
    $.ajax
      url: $(@).data('url')
      method: 'POST'
      data: { name: $(@).data('name') }
      success: =>
        $(@).parents('li').slideUp(300, -> $(@).remove())
    false

  # Filter form: don't send any inputs that are empty
  $('.filter_form').submit ->
    $(@).find(':input').filter(-> @value is '').prop 'disabled', true

  # Filter form: for filters that let you choose the query method from
  # a dropdown, apply that choice to the filter input field.
  $('.filter_form_field.select_and_search select').change ->
    $(@).siblings('input').prop name: "q[#{@value}]"

  # Tab navigation
  $('#active_admin_content .tabs').tabs()

  # In order for index scopes to overflow properly onto the next line, we have
  # to manually set its width based on the width of the batch action button.
  if (batch_actions_selector = $('.table_tools .batch_actions_selector')).length
    batch_actions_selector.next().css
      width: "calc(100% - 10px - #{batch_actions_selector.outerWidth()}px)"
      'float': 'right'
