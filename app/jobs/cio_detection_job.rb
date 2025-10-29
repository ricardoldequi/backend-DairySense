class CioDetectionJob
  include Sidekiq::Job
  sidekiq_options queue: :detectors

  def perform(payload = {})
    p = (payload || {}).transform_keys(&:to_sym)
    animal_id       = p[:animal_id]
    window_minutes  = (p[:window_minutes] || 10).to_i
    z_threshold     = (p[:z_threshold] || 3.0).to_f
    sustain_minutes = (p[:sustain_minutes] || 60).to_i
    since_minutes   = (p[:since_minutes] || 1440).to_i

    scope = animal_id ? Animal.where(id: animal_id) : Animal.all
    scope.find_each do |animal|
      CioDetector.new(
        animal: animal,
        window_minutes: window_minutes,
        z_threshold: z_threshold,
        sustain_minutes: sustain_minutes,
        since: since_minutes.minutes.ago
      ).call
    end
  end
end
