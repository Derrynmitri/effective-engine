class MatchResultsController < ApplicationController
  before_action :set_match_result, only: %i[ show edit update destroy ]
  before_action :set_matches_and_players, only: %i[new edit create update]

  after_action :verify_authorized, except: [ :index ]
  after_action :verify_policy_scoped, only: [ :index ]

  # GET /match_results or /match_results.json
  def index
    @match_results = policy_scope(MatchResult)
  end

  # GET /match_results/1 or /match_results/1.json
  def show
    authorize @match_result
  end

  # GET /match_results/new
  def new
    @match_result = MatchResult.new
    authorize @match_result
  end

  # GET /match_results/1/edit
  def edit
    authorize @match_result
    @match = @match_result.match
  end

  # POST /match_results or /match_results.json
  def create
    @match_result = MatchResult.new(build_match_result_attributes)
    authorize @match_result

    respond_to do |format|
      if @match_result.save
        mark_match_completed(@match_result.match_id, params[:match_result][:played_at])
        format.html { redirect_to @match_result, notice: "Match result was successfully created." }
        format.json { render :show, status: :created, location: @match_result }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @match_result.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /match_results/1 or /match_results/1.json
  def update
    authorize @match_result

    respond_to do |format|
      if @match_result.update(build_match_result_attributes)
        mark_match_completed(@match_result.match_id, params[:match_result][:played_at])
        format.html { redirect_to @match_result, notice: "Match result was successfully updated." }
        format.json { render :show, status: :ok, location: @match_result }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @match_result.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /match_results/1 or /match_results/1.json
  def destroy
    authorize @match_result
    @match_result.destroy!

    respond_to do |format|
      format.html { redirect_to match_results_path, status: :see_other, notice: "Match result was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    def set_match_result
      @match_result = MatchResult.find(params[:id])
    end

    def set_matches_and_players
      if action_name == "new"
        @match_result ||= MatchResult.new
        match_id = params[:match_id]
      else
        match_id = @match_result&.match_id
      end
      if match_id.present?
        match = Match.find_by(id: match_id)
        if match
          @matches = [ match ]
          @players = Player.where(id: [ match.white_player_id, match.black_player_id ]).order(:name, :surname)
        else
          @matches = Match.all.order(:created_at)
          @players = Player.all.order(:name, :surname)
        end
      else
        @matches = Match.all.order(:created_at)
        @players = Player.all.order(:name, :surname)
      end
    end

    def build_match_result_attributes
      attrs = match_result_params.to_h
      draw_param = attrs["draw"]
      if draw_param.to_s == "1" || draw_param == true || draw_param == "true"
        attrs["draw"] = true
        attrs["winner_id"] = nil
        attrs["loser_id"] = nil
      else
        attrs["draw"] = false
        attrs["winner_id"] = attrs["winner_id"].presence
        attrs["loser_id"] = attrs["loser_id"].presence
      end
      attrs
    end

    def mark_match_completed(match_id, played_at_param = nil)
      match = Match.find_by(id: match_id)
      return unless match
      played_at = played_at_param.presence || Time.current
      match.update(status: :completed, played_at: played_at)
    end

    # Only allow a list of trusted parameters through.
    def match_result_params
      params.require(:match_result).permit(:match_id, :winner_id, :loser_id, :draw)
    end
end
