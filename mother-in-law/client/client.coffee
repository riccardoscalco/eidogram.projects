root = this ? exports

# create marker collection
Meteor.subscribe('markers')
root.Markers = new Meteor.Collection('markers')

# resize the layout
root.resize = () ->
  newHeight = $(root).height()
  $("#map").css("height", newHeight)


Template.map.rendered = ->
  # resize on load
  root.resize()

  # resize on resize of root
  $(root).resize =>
    root.resize()
  
  ###
  # create a map in the map div, set the view to a given place and zoom
  root.map = L.map 'map', 
    doubleClickZoom: false
  .setView([49.25044, -123.137], 13)

  # add a CloudMade tile layer with style #997 - use your own cloudmade api key
  L.tileLayer "http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", 
  #L.tileLayer('http://{s}.tile.cloudmade.com/API-key/997/256/{z}/{x}/{y}.png', {
    attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, <a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="http://cloudmade.com">CloudMade</a>'
  .addTo(root.map)
  ###

  # replace "toner" here with "terrain" or "watercolor"
  layer = new L.StamenTileLayer "toner"
  root.map = new L.Map "map", {
      center: new L.LatLng(30, 0)
      zoom: 3
      doubleClickZoom: false
      }
  root.map.addLayer layer

  # create default image path
  L.Icon.Default.imagePath = 'packages/leaflet/images'

  myIcons = L.Icon.extend
    options:
        shadowUrl: '',
        iconSize:     [36, 51],
        shadowSize:   [0, 0],
        iconAnchor:   [18, 51],
        shadowAnchor: [0, 0],
        popupAnchor:  [-3, -76]

  myIcon0 = new myIcons {iconUrl: 'packages/leaflet/images/icoon.svg'}
  # first update file package.js
  #myIcon1 = new myIcons {iconUrl: 'packages/leaflet/images/icoon1.svg'}
  #myIcon2 = new myIcons {iconUrl: 'packages/leaflet/images/icoon2.svg'}
  #myIcon3 = new myIcons {iconUrl: 'packages/leaflet/images/icoon3.svg'}
  #myIcon4 = new myIcons {iconUrl: 'packages/leaflet/images/icoon4.svg'}
  #myIconsList = [myIcon1, myIcon2, myIcon3, myIcon4]

  ###
  root.circle = L.circle [51.508, -0.11], 1000,
    "id": "ciao"
    color: 'red'
    fillColor: '#f03'
    fillOpacity: 0.5
  root.circle.addTo(map)
  ###

  # click on the map and will insert the latlng into the markers collection 
  root.map.on 'click', (e) ->
    if not Session.get("done")?
      id = Markers.insert
        latlng: e.latlng
      Session.set "newDeliver", id
      $("#content-confirm").collapse('show')
      ##if $("#done").hasClass("in")
      ##  $("#done").collapse('hide')

  # watch the markers collection
  query = Markers.find({})
  query.observe
    added: (mark) ->
      #ii = myIconsList[Math.floor Math.random() * (4)]
      root.newMarker = L.marker(mark.latlng, {icon: myIcon0, opacity:0.8})
      .addTo(root.map)