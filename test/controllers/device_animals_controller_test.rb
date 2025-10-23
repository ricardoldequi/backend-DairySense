require "test_helper"

class DeviceAnimalsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @device_animal = device_animals(:one)
  end

  test "should get index" do
    get device_animals_url, as: :json
    assert_response :success
  end

  test "should create device_animal" do
    assert_difference("DeviceAnimal.count") do
      post device_animals_url, params: { device_animal: { animal_id: @device_animal.animal_id, device_id: @device_animal.device_id, end_date: @device_animal.end_date, start_date: @device_animal.start_date } }, as: :json
    end

    assert_response :created
  end

  test "should show device_animal" do
    get device_animal_url(@device_animal), as: :json
    assert_response :success
  end

  test "should update device_animal" do
    patch device_animal_url(@device_animal), params: { device_animal: { animal_id: @device_animal.animal_id, device_id: @device_animal.device_id, end_date: @device_animal.end_date, start_date: @device_animal.start_date } }, as: :json
    assert_response :success
  end

  test "should destroy device_animal" do
    assert_difference("DeviceAnimal.count", -1) do
      delete device_animal_url(@device_animal), as: :json
    end

    assert_response :no_content
  end
end
