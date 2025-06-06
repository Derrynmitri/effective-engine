class PlayersController < ApplicationController
  ITEMS_PER_PAGE = 10
  RECENT_MATCHES_LIMIT = 5
  before_action :authenticate_user!
  before_action :set_player, only: %i[ show edit update destroy ]

  after_action :verify_authorized, except: [ :index ]
  after_action :verify_policy_scoped, only: [ :index ]

  # GET /players or /players.json
  def index
    @players = policy_scope(Player).order(id: :asc).page(params[:page]).per(ITEMS_PER_PAGE)
  end

  # GET /players/1 or /players/1.json
  def show
    authorize @player
    @recent_matches = @player.matches
                             .where(status: :completed)
                             .includes(:white_player, :black_player, :match_result)
                             .order(created_at: :desc)
                             .limit(RECENT_MATCHES_LIMIT)
  end

  # GET /players/new
  def new
    @player = Player.new
    authorize @player
  end

  # GET /players/1/edit
  def edit
    authorize @player
    @player.user_email = @player.user&.email
  end

  # POST /players or /players.json
  def create
    authorize Player

    user = User.new(email: params[:player][:user_email], password: params[:player][:user_password], role: :player)
    if user.save
      @player = Player.new(player_params.merge(user_id: user.id))
    else
      @player = Player.new(player_params)
      @player.errors.add(:base, user.errors.full_messages.join(", "))
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @player.errors, status: :unprocessable_entity }
      end
      return
    end

    respond_to do |format|
      if @player.save
        format.html { redirect_to @player, notice: "Player was successfully created." }
        format.json { render :show, status: :created, location: @player }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @player.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /players/1 or /players/1.json
  def update
    authorize @player

    respond_to do |format|
      if @player.update(player_params)
        format.html { redirect_to @player, notice: "Player was successfully updated." }
        format.json { render :show, status: :ok, location: @player }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @player.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /players/1 or /players/1.json
  def destroy
    authorize @player
    user = @player.user
    @player.destroy!
    if user&.role == "player"
      user.destroy
    end
    respond_to do |format|
      format.html { redirect_to players_path, status: :see_other, notice: "Player was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_player
      @player = Player.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def player_params
      params.require(:player).permit(:name, :surname, :birthday, :user_id, :user_email)
    end
end
