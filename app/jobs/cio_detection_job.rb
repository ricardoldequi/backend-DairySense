class CioDetectionJob
  include Sidekiq::Job
  sidekiq_options queue: :default

  # Args:
  # - animal_id: filtra um animal específico (opcional)
  # - window_minutes: tamanho da janela para ENMO (default 10)
  # - z_threshold: limiar de z-score (default 3.0)
  # - sustain_minutes: minutos acumulados acima do limiar para alertar (default 40)
  # - since_minutes: janela para trás a partir de agora (default 180)
  def perform(animal_id: nil, window_minutes: 10, z_threshold: 3.0, sustain_minutes: 40, since_minutes: 180)
    scope = animal_id.present? ? Animal.where(id: animal_id) : Animal.all
    scope.find_each do |animal|
      CioDetector.new(
        animal: animal,
        window_minutes: window_minutes,
        z_threshold: z_threshold,
        sustain_minutes: sustain_minutes,
        since: since_minutes.to_i.minutes.ago
      ).call
    end
  end
end
