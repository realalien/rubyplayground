#encoding: UTF-8

#Purpose: collect communities data from ddmap website



require File.join(File.dirname(__FILE__), '../../hackingLBS/ddmap_resources.rb')

require 'pp'

a = collect_places_by_city_sublocality_category("21", "虹口区", "住宅小区")

pp a