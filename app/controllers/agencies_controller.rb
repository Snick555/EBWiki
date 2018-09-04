# frozen_string_literal: true

# Agencies Controller
class AgenciesController < ApplicationController
  before_action :set_agency, only: %i[show edit update destroy]
  before_action :authenticate_user!, except: %i[index show]
  before_action :save_my_previous_url, only: %i[new show edit]

  # GET /agencies
  def index
    @agencies = SortCollectionOrdinally.call(Agency.all)
  end

  # GET /agencies/1
  def show
    @back_url = session[:previous_url]
    @cases = @agency.cases
    @agency_state = @agency.retrieve_state
  end

  # GET /agencies/new
  def new
    @agency = Agency.new
  end

  # GET /agencies/1/edit
  def edit; end

  # POST /agencies
  def create
    @back_url = session[:previous_url]
    @agency = Agency.new(agency_params.except(:jurisdiction))
    @agency.jurisdiction_type = agency_params[:jurisdiction]
    respond_to do |format|
      if @agency.save
        format.html {redirect_to @back_url,
          notice: 'Agency was successfully created.',
          status: :created
        }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /agencies/1
  def update
    respond_to do |format|
      if @agency.update(agency_params.except(:jurisdiction))
        @agency.jurisdiction_type = agency_params[:jurisdiction]
        format.html { redirect_to @agency, notice: 'Agency was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /agencies/1
  def destroy
    @agency.destroy
    respond_to do |format|
      format.html { redirect_to agencies_url, notice: 'Agency was successfully destroyed.' }
    end
  end

  private

  def after_sign_up_path_for(resource)
    stored_location_for(resource) || super
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || super
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_agency
    @agency = Agency.friendly.find(params[:id])
  end

  def save_my_previous_url
    # session[:previous_url] is a Rails built-in variable to save last url.
    session[:previous_url] = URI(request.referer || '').path
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def agency_params
    params.require(:agency).permit(I18n.t('agencies_controller.agency_params').map(&:to_sym))
  end
end
