json.array!(@exports) do |export|
  json.extract! export, :name, :file, :project_id, :status, :viewed, :file_created_at, :details, :include_xls, :include_csv_labeled, :include_csv_raw, :include_pdf, :include_files, :include_data_dictionary, :user_id, :created_at, :updated_at
  json.path export_path(export, format: :json)
  # json.url export_url(export, format: :json)
end
