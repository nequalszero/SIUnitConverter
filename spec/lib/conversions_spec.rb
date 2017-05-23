require 'rails_helper'
require_relative '../../lib/conversions'

describe "SI_UNIT_COUNTERPARTS" do
  context "object structure" do
    it "is a hash" do
      expect(SI_UNIT_COUNTERPARTS.class).to eq(Hash)
    end

    it "has values that are each hashes with :unit and :factor keys" do
      hash_length = SI_UNIT_COUNTERPARTS.length
      valid_count = 0
      SI_UNIT_COUNTERPARTS.values.each { |val| valid_count += 1 if (val.has_key?(:unit) && val.has_key?(:factor)) }
      expect(valid_count).to eq(hash_length)
    end
  end

  context "time conversions" do
    it "converts 'minute' to 60s" do
      expect(SI_UNIT_COUNTERPARTS["minute"][:factor]).to eq(60)
      expect(SI_UNIT_COUNTERPARTS["minute"][:unit]).to eq('s')
    end

    it "converts 'min' to 60s" do
      expect(SI_UNIT_COUNTERPARTS["min"][:factor]).to eq(60)
      expect(SI_UNIT_COUNTERPARTS["min"][:unit]).to eq('s')
    end

    it "converts 'hour' to 3600s" do
      expect(SI_UNIT_COUNTERPARTS["hour"][:factor]).to eq(3600)
      expect(SI_UNIT_COUNTERPARTS["hour"][:unit]).to eq('s')
    end

    it "converts 'h' to 3600s" do
      expect(SI_UNIT_COUNTERPARTS["h"][:factor]).to eq(3600)
      expect(SI_UNIT_COUNTERPARTS["h"][:unit]).to eq('s')
    end

    it "converts 'day' to 86400s" do
      expect(SI_UNIT_COUNTERPARTS["day"][:factor]).to eq(86400)
      expect(SI_UNIT_COUNTERPARTS["day"][:unit]).to eq('s')
    end

    it "converts 'd' to 86400s" do
      expect(SI_UNIT_COUNTERPARTS["d"][:factor]).to eq(86400)
      expect(SI_UNIT_COUNTERPARTS["d"][:unit]).to eq('s')
    end
  end

  context "plane angle conversions" do
    it "converts 'degree' to (π / 180) rad" do
      expect(SI_UNIT_COUNTERPARTS["degree"][:factor]).to eq(Math::PI/180)
      expect(SI_UNIT_COUNTERPARTS["degree"][:unit]).to eq('rad')
    end

    it "converts '°' to (π / 180) rad" do
      expect(SI_UNIT_COUNTERPARTS["°"][:factor]).to eq(Math::PI/180)
      expect(SI_UNIT_COUNTERPARTS["°"][:unit]).to eq('rad')
    end

    it "converts '\'' to (π / 10800) rad" do
      expect(SI_UNIT_COUNTERPARTS["\'"][:factor]).to eq(Math::PI/10800)
      expect(SI_UNIT_COUNTERPARTS["\'"][:unit]).to eq('rad')
    end

    it "converts 'second' to (π / 648000) rad" do
      expect(SI_UNIT_COUNTERPARTS["second"][:factor]).to eq(Math::PI/648000)
      expect(SI_UNIT_COUNTERPARTS["second"][:unit]).to eq('rad')
    end

    it "converts '\"' to (π / 648000) rad" do
      expect(SI_UNIT_COUNTERPARTS["\""][:factor]).to eq(Math::PI/648000)
      expect(SI_UNIT_COUNTERPARTS["\""][:unit]).to eq('rad')
    end
  end

  context "area conversion" do
    it "converts 'hectare' to 10000m^2" do
      expect(SI_UNIT_COUNTERPARTS["hectare"][:factor]).to eq(10000)
      expect(SI_UNIT_COUNTERPARTS["hectare"][:unit]).to eq('m^2')
    end

    it "converts 'ha' to 10000m^2" do
      expect(SI_UNIT_COUNTERPARTS["ha"][:factor]).to eq(10000)
      expect(SI_UNIT_COUNTERPARTS["ha"][:unit]).to eq('m^2')
    end
  end

  context "volume conversion" do
    it "converts 'litre' to 0.001m^3" do
      expect(SI_UNIT_COUNTERPARTS["litre"][:factor]).to eq(0.001)
      expect(SI_UNIT_COUNTERPARTS["litre"][:unit]).to eq('m^3')
    end

    it "converts 'L' to 0.001m^3" do
      expect(SI_UNIT_COUNTERPARTS["L"][:factor]).to eq(0.001)
      expect(SI_UNIT_COUNTERPARTS["L"][:unit]).to eq('m^3')
    end
  end

  context "mass conversion" do
    it "converts 'tonne' to 10**3kg" do
      expect(SI_UNIT_COUNTERPARTS["tonne"][:factor]).to eq(10**3)
      expect(SI_UNIT_COUNTERPARTS["tonne"][:unit]).to eq('kg')
    end

    it "converts 't' to 10**3kg" do
      expect(SI_UNIT_COUNTERPARTS["t"][:factor]).to eq(10**3)
      expect(SI_UNIT_COUNTERPARTS["t"][:unit]).to eq('kg')
    end
  end
end
