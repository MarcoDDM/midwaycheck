require 'net/http'
require 'json'

class LocationsController < ApplicationController
  def new
    @address1 = params[:address1]
    @address2 = params[:address2]
  end

  def create
    address1 = params[:address1]
    address2 = params[:address2]

    coords1 = geocode(address1)
    coords2 = geocode(address2)

    if coords1 && coords2
      @midpoint = find_midpoint(coords1, coords2)
      @places = find_places(@midpoint)
    else
      flash.now[:alert] = "No se pudieron geocodificar una o ambas direcciones."
      render :new
    end
  rescue StandardError => e
    flash.now[:alert] = "Ocurrió un error al procesar la búsqueda: #{e.message}"
    render :new
  end

  private

  def geocode(address)
    api_key = Rails.application.credentials.dig(:google_maps, :api_key)
    url = URI("https://maps.googleapis.com/maps/api/geocode/json?address=#{URI.encode_www_form_component(address)}&key=#{api_key}")
    response = Net::HTTP.get(url)
    data = JSON.parse(response)

    if data['status'] == 'OK'
      location = data['results'][0]['geometry']['location']
      [location['lat'], location['lng']]
    else
      nil
    end
  end

  def find_midpoint(coords1, coords2)
    lat = (coords1[0] + coords2[0]) / 2.0
    lng = (coords1[1] + coords2[1]) / 2.0
    [lat, lng]
  end

  def find_places(midpoint)
    api_key = Rails.application.credentials.dig(:google_maps, :api_key)
    lat, lng = midpoint
    radius = 5000 # Radio en metros para buscar lugares
    types = 'cafe|bar|shopping_mall|park'
    url = URI("https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{lat},#{lng}&radius=#{radius}&type=#{types}&key=#{api_key}")
    response = Net::HTTP.get(url)
    places = JSON.parse(response)['results'].first(5)

    places.each do |place|
      if place['photos']
        place['photo_url'] = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=#{place['photos'][0]['photo_reference']}&key=#{api_key}"
      else
        place['photo_url'] = nil
      end
    end

    places
  end
end
