$ ->
  $('#shoppingCart').height($("html").height())

$(document).on 'click', '#checkoutBtn', (event) ->
  event.preventDefault()
  event.stopPropagation()
  if $(@).hasClass('disabled') then return
  $('#priorityModal').modal('toggle')
  $(".cartEntry").each (index, element) ->
    itemName = $(@).data('name')
    itemPrice = $(@).data('price')
    buying = $(@).children('.numInCart').val()
    if $("#priorityTable ##{itemName}").length is 0
      $("#priorityTable").append """
        <tr class='priorityRow' id='#{itemName}' data-name='#{itemName}' data-buying='#{buying}'>
          <td><strong>#{itemName}</strong></td>
          <td>#{itemPrice}</td>
          <td class='priorityButtons'>
            <div class="btn-group" data-toggle="buttons-radio">
              <button type="button" class="btn btn-small btn-info">Low</button>
              <button type="button" class="btn btn-small btn-info active">Neutral</button>
              <button type="button" class="btn btn-small btn-info">High</button>
            </div>
          </td>
        </tr>
      """

$(document).on 'click', '.thumbnail', (event) ->
  event.preventDefault()
  event.stopPropagation()
  $item = $(@)
  itemName = $item.data('name')
  itemPrice = $item.data('price')
  itemQuantity = $item.data('quantity')
  inCartAlready = false
  $('#checkoutBtn').removeClass('disabled')
  $(".cartEntry").each (index, element) =>
    if $(element).data('name') is itemName then inCartAlready = true
  itemEntry = """
      <div class='cartEntry' data-name='#{itemName}'
        data-price='#{itemPrice}' data-quantity='#{itemQuantity}'>
        <input type='number' class='numInCart pull-right' value='1' min='1'
           max='#{itemQuantity}' />
        <div class='pull-left itemSummary'>
          <span>
            <button class="close pull-left removeItem">&times;</button>
            <h4>#{itemName}
              <small>#{itemPrice}</small>
            </h4>
          </span>
        </div>
      </div>
  """
  if not inCartAlready then $("#shoppingCart").append itemEntry

$(document).on 'change', '.numInCart', (event) ->
  newVal = +$(@).val()
  minVal = +$(@).attr('min')
  maxVal = +$(@).attr('max')
  validQuantity = maxVal >= newVal >= minVal
  if not validQuantity
    if newVal < minVal
      $(@).val(minVal)
    else if newVal > maxVal
      $(@).val(maxVal)
    else
      $(@).val(minVal)

$(document).on 'click', '.removeItem', (event) ->
  event.preventDefault()
  event.stopPropagation()
  $(@).parents('.cartEntry').remove()
  if $('#shoppingCart .cartEntry').length is 0 then $('#checkoutBtn').addClass('disabled')

renderPurchaseSummary = (data) ->
  resultStatus = data.status
  if resultStatus is 'KO'
    console.log "There was an error"
    console.log data
    return
  budget = data.budget
  value  = data.value
  spent  = data.spent
  buying = data.buying

$(document).on 'click', '#startShopping', (event) ->
  event.preventDefault()
  event.stopPropagation()
  budget = $("#budgetInput").val()
  budget = +budget
  if not budget
    $('#priorityModal .control-group').addClass('error')
    $('#budgetInput').tooltip({
      title: 'Enter your balance'
    }).tooltip('show')
  else
    $('#priorityModal .control-group').removeClass('error')
    $('#budgetInput').tooltip('destroy')
    $('#priorityModal').modal('toggle')
    url = "/checkout"
    resultObj =
      budget: budget
      items : []
    $('.priorityRow').each (index, element) ->
      elementObj = {}
      elementObj.name = $(element).data 'name'
      elementObj.buying = $(element).data 'buying'
      priorityText = $(element).children('.priorityButtons')
                              .children().children('.active').text()
      switch priorityText
        when 'Low' then elementObj.priority = 1
        when 'Neutral' then elementObj.priority = 2
        when 'High' then elementObj.priority = 3
        else elementObj.priority = 0

      resultObj.items.push elementObj
    $.ajax url,
      data : JSON.stringify(resultObj)
      contentType : 'application/json'
      type : 'POST'
      success: (data) ->
        console.log data