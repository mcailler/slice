class SubjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_viewable_project, only: [ :index, :show ]
  before_action :set_editable_project, only: [ :new, :edit, :create, :update, :destroy ]
  before_action :redirect_without_project, only: [ :index, :show, :new, :edit, :create, :update, :destroy ]
  before_action :set_viewable_subject, only: [ :show ]
  before_action :set_editable_subject, only: [ :edit, :update, :destroy ]
  before_action :redirect_without_subject, only: [ :show, :edit, :update, :destroy ]


  # GET /subjects
  # GET /subjects.json
  def index
    current_user.pagination_set!('subjects', params[:subjects_per_page].to_i) if params[:subjects_per_page].to_i > 0

    @order = scrub_order(Subject, params[:order], 'subjects.subject_code')
    @statuses = params[:statuses] || ['valid', 'pending', 'test']
    subject_scope = current_user.all_viewable_subjects.where(project_id: @project.id).where(status: @statuses).search(params[:search]).order(@order)
    subject_scope = subject_scope.where(site_id: params[:site_id]) unless params[:site_id].blank?
    subject_scope = subject_scope.without_design(params[:without_design_id]) unless params[:without_design_id].blank?

    @subjects = subject_scope.page(params[:page]).per( current_user.pagination_count('subjects') )

    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @subjects }
    end
  end

  # GET /subjects/1
  # GET /subjects/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @subject }
    end
  end

  # GET /subjects/new
  # GET /subjects/new.json
  def new
    @subject = current_user.subjects.new(post_params)

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @subject }
    end
  end

  # GET /subjects/1/edit
  def edit

  end

  # POST /subjects
  # POST /subjects.json
  def create
    @subject = current_user.subjects.new(post_params)

    respond_to do |format|
      if @subject.save
        format.html { redirect_to [@project, @subject], notice: 'Subject was successfully created.' }
        format.json { render json: @subject, status: :created, location: @subject }
      else
        format.html { render action: "new" }
        format.json { render json: @subject.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /subjects/1
  # PUT /subjects/1.json
  def update
    respond_to do |format|
      if @subject.update_attributes(post_params)
        format.html { redirect_to [@project, @subject], notice: 'Subject was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @subject.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /subjects/1
  # DELETE /subjects/1.json
  def destroy
    @subject.destroy

    respond_to do |format|
      format.html { redirect_to project_subjects_path(@project) }
      format.js { render 'destroy' }
      format.json { head :no_content }
    end
  end

  private

  def post_params
    params[:subject] ||= {}

    params[:subject][:site_id] = params[:site_id]

    if current_user.all_viewable_projects.pluck(:id).include?(params[:project_id].to_i)
      params[:subject][:project_id] = params[:project_id]
    else
      params[:subject][:project_id] = nil
    end

    params[:subject].slice(
      :project_id, :subject_code, :site_id, :acrostic, :email, :status
    )
  end

  def set_viewable_subject
    @subject = current_user.all_viewable_subjects.find_by_id(params[:id])
  end

  def set_editable_subject
    @subject = @project.subjects.find_by_id(params[:id])
  end

  def redirect_without_subject
    empty_response_or_root_path(project_subjects_path) unless @subject
  end

end
