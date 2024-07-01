require 'net/http'
require 'json'

class LocationsController < ApplicationController
  def new
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
      flash[:alert] = "No se pudieron geocodificar una o ambas direcciones."
      render :new and return
    end
  end

  private

  def geocode(address)
    api_key = Rails.application.credentials.dig(:google_maps, :api_key)
    encoded_address = URI.encode_www_form_component(address)
    url = URI("https://maps.googleapis.com/maps/api/geocode/json?address=#{encoded_address}&key=#{api_key}")
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
    JSON.parse(response)['results']
  end
end
