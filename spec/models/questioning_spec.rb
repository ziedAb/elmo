require 'spec_helper'

describe Questioning do
  it_behaves_like "has a uuid"

  it "previous" do
    f = create(:form, :question_types => %w(integer decimal integer))
    expect(f.questionings.last.previous).to eq(f.questionings[0..1])
  end

  it "mission should get copied from question on creation" do
    f = create(:form, :question_types => %w(integer), :mission => get_mission)
    expect(f.questionings[0].mission).to eq(get_mission)
  end

  describe "normalization" do
    # Run valid? to trigger normalization
    let(:q_attrs) { {} }
    let(:question) { create(:question, q_attrs) }
    let(:qing) { build(:questioning, submitted.merge(question: question)).tap(&:valid?) }
    subject { submitted.keys.map { |k| [k, qing.send(k)] }.to_h }

    describe "hidden/required/read_only" do
      context do
        let(:submitted) { {hidden: true, required: true, read_only: false} }
        it { is_expected.to eq(hidden: true, required: false, read_only: false) }
      end

      context do
        let(:submitted) { {hidden: true, required: false, read_only: false} }
        it { is_expected.to eq(hidden: true, required: false, read_only: false) }
      end

      context do
        let(:submitted) { {hidden: false, required: true, read_only: false} }
        it { is_expected.to eq(hidden: false, required: true, read_only: false) }
      end

      context do
        let(:submitted) { {hidden: false, required: true, read_only: true} }
        it { is_expected.to eq(hidden: false, required: false, read_only: true) }
      end

      context do
        let(:submitted) { {hidden: false, required: false, read_only: true} }
        it { is_expected.to eq(hidden: false, required: false, read_only: true) }
      end
    end

    describe "question metadata and hidden/required" do
      context do
        let(:q_attrs) { {qtype_name: "datetime", metadata_type: "formstart"} }
        let(:submitted) { {required: true, hidden: false} }
        it { is_expected.to eq(required: false, hidden: true) }
      end

      context do
        let(:q_attrs) { {qtype_name: "datetime", metadata_type: "formstart"} }
        let(:submitted) { {required: "", hidden: true} }
        it { is_expected.to eq(required: false, hidden: true) }
      end

      context do
        let(:q_attrs) { {qtype_name: "datetime", metadata_type: ""} }
        let(:submitted) { {required: true, hidden: false} }
        it { is_expected.to eq(required: true, hidden: false) }
      end
    end

    describe "question metadata and condition" do
      let(:condition) { build(:condition) }

      context do
        let(:q_attrs) { {qtype_name: "datetime", metadata_type: nil} }
        let(:submitted) { {condition: condition} }
        it { is_expected.to eq(condition: condition) }
      end

      context do
        let(:q_attrs) { {qtype_name: "datetime", metadata_type: "formstart"} }
        let(:submitted) { {condition: condition} }
        it do
          is_expected.to eq(condition: nil)
          expect(condition).to be_destroyed
        end
      end

      context do
        let(:q_attrs) { {qtype_name: "datetime", metadata_type: "formstart"} }
        let(:submitted) { {condition: nil} }
        it { is_expected.to eq(condition: nil) }
      end
    end
  end
end
