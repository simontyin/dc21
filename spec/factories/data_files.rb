# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :data_file do
    sequence(:filename) { |n| "file-#{n}" }
    path "a-path"
    association :created_by, :factory => :user
    association :published_by, :factory => :user
    association :experiment
    file_processing_status "RAW"
    file_size 10000
  end
end