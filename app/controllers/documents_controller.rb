class DocumentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_viewable_project, only: [ :file ]
  before_action :set_editable_project, only: [ :index, :show, :new, :edit, :create, :update, :destroy ]
  before_action :redirect_without_project, only: [ :index, :show, :new, :edit, :create, :update, :destroy, :file ]
  before_action :set_viewable_document, only: [ :file ]
  before_action :set_editable_document, only: [ :show, :edit, :update, :destroy ]
  before_action :redirect_without_document, only: [ :show, :edit, :update, :destroy, :file ]

  def file
    if @document.file.size > 0
      send_file File.join( CarrierWave::Uploader::Base.root, @document.file.url )
    else
      render nothing: true
    end
  end

  # GET /documents
  # GET /documents.json
  def index
    @order = scrub_order(Document, params[:order], "documents.name")
    @documents = @project.documents.search(params[:search]).order(@order).page(params[:page]).per( 20 )
  end

  # GET /documents/1
  # GET /documents/1.json
  def show
  end

  # GET /documents/new
  def new
    @document = @project.documents.new
  end

  # GET /documents/1/edit
  def edit
  end

  # POST /documents
  # POST /documents.json
  def create
    @document = @project.documents.new(document_params)

    respond_to do |format|
      if @document.save
        format.html { redirect_to [@document.project, @document], notice: 'Document was successfully created.' }
        format.json { render action: 'show', status: :created, location: @document }
      else
        format.html { render action: 'new' }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /documents/1
  # PUT /documents/1.json
  def update
    respond_to do |format|
      original_category = @document.category
      if @document.update(document_params)
        @project.documents.where( category: original_category ).update_all( category: @document.category ) if params[:rename_category] == '1'
        format.html { redirect_to [@document.project, @document], notice: 'Document was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /documents/1
  # DELETE /documents/1.json
  def destroy
    @document.destroy

    respond_to do |format|
      format.html { redirect_to project_documents_path(@project) }
      format.json { head :no_content }
    end
  end

  private

    def set_viewable_document
      @document = @project.documents.find_by_id(params[:id])
    end

    def set_editable_document
      @document = @project.documents.find_by_id(params[:id])
    end

    def redirect_without_document
      empty_response_or_root_path(project_documents_path(@project)) unless @document
    end

    def document_params
      params[:document] ||= {}

      params[:document][:user_id] = current_user.id unless @document

      params.require(:document).permit(
        :name, :category, :file, :file_cache, :archived, :user_id
      )
    end

end
