require 'rails_helper'
require_relative '../../lib/si_unit_string'

describe "SIUnitString" do
  it "can instantiate a new class" do
    si_unit_string = SIUnitString.new('abc')
    expect(200).to eq(200)
  end

  it "removes white space" do
    si_unit_string = SIUnitString.new(' a b c ')
    expect(si_unit_string.string).to eq('abc')
  end

  context "#parse" do
    describe "unit strings without parenthesis" do
      let(:string1) { SIUnitString.new("degree") }
      let(:string2) { SIUnitString.new("degree/minute") }
      let(:string3) { SIUnitString.new("degree*ha/minute") }
      let(:string4) { SIUnitString.new("degree * ha / minute / ° / ° * \' * \"") }

      it "can parse a string with one unit" do
        expect(string1.parse).to eq({
          unit_name: "rad",
          multiplication_factor: (Math::PI/180).round(14)
        })
      end

      it "can parse a string with two units" do
        expect(string2.parse).to eq({
          unit_name: "rad/s",
          multiplication_factor: (Math::PI/180/60).round(14)
        })
      end

      it "can parse a string with three units" do
        expect(string3.parse).to eq({
          unit_name: "rad*m^2/s",
          multiplication_factor: (Math::PI/180*10000/60).round(14)
        })
      end

      it "can parse a string with many units" do
        expected_units = "rad*m^2/s/rad/rad*rad*rad"
        expected_factor = (Math::PI/180*10000/60/(Math::PI/180)/(Math::PI/180)*(Math::PI/10800)*(Math::PI/648000)).round(14)

        expect(string4.parse).to eq({
          unit_name: expected_units,
          multiplication_factor: expected_factor
        })
      end
    end

    describe "unit strings with parenthesis" do
      let(:string1) { SIUnitString.new("(degree)") }
      let(:string2) { SIUnitString.new("(degree/minute)") }
      let(:string3) { SIUnitString.new("(degree*ha)/minute") }
      let(:string4) { SIUnitString.new("(degree * ha) / (minute * ° * °) * (\' * \")") }

      context "unit strings with parenthesis only" do
        it "can parse a unitless string with one set of parenthesis" do
          expect(SIUnitString.new('()').parse).to eq({unit_name: '()', multiplication_factor: 1.0})
        end

        it "can parse a unitless string with two sets of parenthesis" do
          expect(SIUnitString.new('()()').parse).to eq({unit_name: '()()', multiplication_factor: 1.0})
        end

        it "can parse a unitless string with two sets of parenthesis that are nested" do
          expect(SIUnitString.new('(())').parse).to eq({unit_name: '(())', multiplication_factor: 1.0})
        end

        it "can parse a unitless string with three sets of parenthesis that are nested" do
          expect(SIUnitString.new('((()))').parse).to eq({unit_name: '((()))', multiplication_factor: 1.0})
        end

        it "can parse a unitless string with multiple sets of parenthesis" do
          expect(SIUnitString.new('(()())').parse).to eq({unit_name: '(()())', multiplication_factor: 1.0})
          expect(SIUnitString.new('(()()())').parse).to eq({unit_name: '(()()())', multiplication_factor: 1.0})
          expect(SIUnitString.new('(()()())').parse).to eq({unit_name: '(()()())', multiplication_factor: 1.0})
          expect(SIUnitString.new('(())(()())').parse).to eq({unit_name: '(())(()())', multiplication_factor: 1.0})
        end
      end

      context "unit strings with units and parenthesis" do
        it "can parse a string with one unit" do
          expect(string1.parse).to eq({
            unit_name: "(rad)",
            multiplication_factor: (Math::PI/180).round(14)
          })
        end

        it "can parse a string with two units" do
          expect(string2.parse).to eq({
            unit_name: "(rad/s)",
            multiplication_factor: (Math::PI/180/60).round(14)
          })
        end

        it "can parse a string with three units" do
          expect(string3.parse).to eq({
            unit_name: "(rad*m^2)/s",
            multiplication_factor: (Math::PI/180*10000/60).round(14)
          })
        end

        it "can parse a string with many units and parenthesis groupings" do
          expected_units = "(rad*m^2)/(s*rad*rad)*(rad*rad)"
          expected_factor = (Math::PI/180*10000/60/(Math::PI/180)/(Math::PI/180)*(Math::PI/10800)*(Math::PI/648000)).round(14)

          expect(string4.parse).to eq({
            unit_name: expected_units,
            multiplication_factor: expected_factor
          })
        end
      end
    end
  end
end
