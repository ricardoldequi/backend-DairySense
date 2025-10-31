module Api
  class DashboardController < ApplicationController
    before_action :authorize

    def stats
      active_collars = Device.count
      total_animals = Animal.count
      today_readings = Reading.where('DATE(created_at) = ?', Date.current).count
      alerts = 0 # placeholder

      render json: {
        activeCollars: active_collars,
        totalAnimals: total_animals,
        todayReadings: today_readings,
        alerts: alerts
      }
    end
  end
end