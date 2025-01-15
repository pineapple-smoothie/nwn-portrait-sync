class CharacterPolicy < ApplicationPolicy
  def index?
    true
  end

  def mine?
    true
  end

  def new?
    true
  end

  def download_all_portraits?
    true
  end

  def create?
    record.user == user
  end

  def edit?
    record.user == user
  end

  def update?
    record.user == user
  end

  def destroy?
    record.user == user
  end
end
