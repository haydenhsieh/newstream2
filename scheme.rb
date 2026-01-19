Sequel::Model.db.create_table :feeds do
  primary_key :id
  String :stream
  String :title
  DateTime :date
  String :url
  String :state
end
