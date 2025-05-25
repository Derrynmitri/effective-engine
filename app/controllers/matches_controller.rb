class MatchesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_match, only: %i[ show edit update destroy ]
  skip_before_action :authenticate_user!, only: [ :index, :show ]

  after_action :verify_authorized
  after_action :verify_policy_scoped, only: [ :index ]


  # GET /matches or /matches.json
  def index
    @matches = policy_scope(Match)
    authorize @matches
  end

  # GET /matches/1 or /matches/1.json
  def show
    authorize @match
  end

  # GET /matches/new
  def new
    @match = Match.new
    @players = Player.all.order(:name, :surname)
    authorize @match
  end

  # GET /matches/1/edit
  def edit
    @players = Player.all.order(:name, :surname)
    authorize @match
  end

  # POST /matches or /matches.json
  def create
    @match = Match.new(match_params)
    authorize @match

    respond_to do |format|
      if @match.save
        format.html { redirect_to @match, notice: "Match was successfully created." }
        format.json { render :show, status: :created, location: @match }
      else
        authorize @match # Ensure authorization before rendering :new
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @match.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /matches/1 or /matches/1.json
  def update
    authorize @match

    respond_to do |format|
      if @match.update(match_params)
        format.html { redirect_to @match, notice: "Match was successfully updated." }
        format.json { render :show, status: :ok, location: @match }
      else
        authorize @match # Ensure authorization before rendering :edit
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @match.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /matches/1 or /matches/1.json
  def destroy
    authorize @match

    @match.destroy!

    respond_to do |format|
      format.html { redirect_to matches_path, status: :see_other, notice: "Match was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_match
      @match = Match.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def match_params
      params.require(:match).permit(:white_player_id, :black_player_id, :status, :played_at)
    end
end
