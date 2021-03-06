###
This file handles the main detail panel that users will use for a more in-depth
view of Cilkpride's information. It appears as a panel on the bottom of the screen,
and a separate detail panel should be created for each active Cilkpride project.
###

$ = require('jquery')

Debug = require('./utils/debug')

module.exports =
class CilkprideDetailPanel

  props: null             # object holding properties defined by parent class
  onCloseCallback: null   # callback to close/hide the detail panel

  element: null           # detail panel container element
  header: null            # detail panel header element
  moduleContainer: null   # detail panel div containing module information

  currentTab: null        # the Tab object corresponding to the currently selected module

  constructor: (props) ->
    @props = props
    @onCloseCallback = props.onCloseCallback

    # Create root element
    @element = document.createElement('div')
    @element.classList.add('cilkpride-detail-panel', 'table')

    resizeDiv = document.createElement('div')
    resizeDiv.classList.add('cilkpride-detail-resize')

    @element.appendChild(resizeDiv)
    $(resizeDiv).on('mousedown', @resizeStart)

    @header = document.createElement('div')
    @header.classList.add('header', 'table-row')
    close = document.createElement('div')
    close.classList.add('header-close', 'icon', 'icon-x')
    $(close).on('click', () =>
      @onCloseCallback()
      @currentTab.view.resetUI() if @currentTab
    )
    @header.appendChild(close)

    @element.appendChild(@header)

    # The actual module information (Cilksan, Cilkprof, etc.) goes in this div.
    @moduleContainer = document.createElement('div')
    @moduleContainer.classList.add('cilkpride-module-view-container', 'table-row')

    @element.appendChild(@moduleContainer)

  resizeStart: () =>
    $(document).on('mousemove', @resizeMove)
    $(document).on('mouseup', @resizeStop)

  resizeStop: () =>
    $(document).off('mousemove', @resizeMove)
    $(document).off('mouseup', @resizeStop)

  resizeMove: (event) =>
    return @resizeStop() unless event.which is 1

    element = $(@element)
    # Debug.log("Horizontal resize move")
    height = element.offset().top + element.outerHeight() - event.pageY
    element.height(height)

  clickTab: (newTab) ->
    if @currentTab is newTab
      return

    if @currentTab
      @currentTab.getElement().classList.remove('selected')
      @currentTab.view.resetUI()
    @currentTab = newTab
    newTab.getElement().classList.add('selected')
    $(@moduleContainer.firstChild).detach()
    @moduleContainer.appendChild(@currentTab.view.getElement())

  registerModuleTab: (name, view) ->
    tab = new Tab({name: name, onClickCallback: ((tab) => @clickTab(tab, name)), view: view})
    @header.appendChild(tab.getElement())
    # Sets a default tab to open to when the detail panel is shown.
    if not @currentTab
      @clickTab(tab)
    return tab

###
Class representing the clicktable tabs in the detail panel header. Allows users
to switch what information they're looking at.
###
class Tab
  element: null
  onClickCallback: null
  view: null

  constructor: (props) ->
    @onClickCallback = props.onClickCallback
    @view = props.view

    @element = document.createElement('div')
    @element.classList.add('cilkpride-tab', 'inline-block')
    @icon = document.createElement('span')
    @icon.textContent = props.name
    @element.appendChild(@icon)
    $(@element).on('click', (e) =>
      @onClickCallback(this)
    )

  setState: (state) ->
    Debug.log("[tab] setting state to #{state}")
    @resetState()
    if state is "ok"
      @icon.classList.add('icon', 'icon-check')
    else if state is "execution_error"
      @icon.classList.add('icon', 'icon-x')
    else if state is "error"
      @icon.classList.add('icon', 'icon-issue-opened')
    else if state is "busy"
      @icon.classList.add('icon', 'icon-clock')
    else if state is "initializing"
      @icon.classList.add('icon', 'icon-sync')
    else if state is "start"
      @icon.classList.add('icon', 'icon-question')

  resetState: () ->
    @icon.className = ""

  # Programatically force a click (for module use)
  click: () ->
    @onClickCallback(this)

  getElement: () ->
    return @element
