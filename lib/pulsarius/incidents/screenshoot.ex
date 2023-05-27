defmodule Pulsarius.Incidents.Screenshot do
  @bucket_name Application.get_env(:ex_aws, :bucket_name)

  def take_screenshot(url, filename) do
    filename = "#{filename}.jpeg"
    path = "./#{filename}"

    options = [
      type: "jpeg",
      path: path,
      timeout: 50000
    ]

    case PuppeteerImg.generate_image(url, options) do
      {:ok, path} ->
        path
        |> upload_to_s3(filename)
        |> remove_file(path)
        |> return_image_url(filename)

      {:error, error} ->
        {:error, error}
    end
  end

  defp upload_to_s3(path, filename) do
    {:ok, image_binary} = File.read(path)
    filename = "#{filename}.jpeg"

    ExAws.S3.put_object(@bucket_name, filename, image_binary)
    |> ExAws.request!()
  end

  defp remove_file(%{status_code: 200}, path) do
    File.rm(path)
  end

  defp return_image_url(:ok, filename) do
    image_url = "https://#{@bucket_name}.s3.amazonaws.com/#{@bucket_name}/#{filename}"
    {:ok, image_url}
  end

  defp return_image_url(error, _filename) do
    error
  end
end
