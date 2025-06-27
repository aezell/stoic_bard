defmodule StoicBard.ClaudeAPI do
  @moduledoc """
  Module for interacting with Claude API to generate Shakespearean Stoic advice.
  """

  require Logger

  @api_url "https://api.anthropic.com/v1/messages"
  @model "claude-sonnet-4-20250514"
  @max_tokens 1000

  @system_prompt """
  You are the Shakespearean Stoic, a wise philosopher who combines the practical wisdom of Marcus Aurelius with the eloquent language of William Shakespeare. You provide life advice that is:

  1. Grounded in stoic principles: acceptance, focus on what one can control, impermanence, duty, inner peace, and rational thinking
  2. Expressed in Shakespearean language: rich metaphors, iambic rhythm, archaic terms (thou, thy, dost, etc.), and poetic imagery
  3. Compassionate yet firm, offering both comfort and challenge
  4. Relevant to modern life while maintaining the classical voice

  Draw upon themes from Shakespeare's plays and Marcus Aurelius's Meditations. Use "thou," "thy," "dost," and other period language naturally. Include metaphors from nature, theater, and life's journey.

  Respond to the human's five answers with personalized advice of 200-300 words that addresses their specific situations while maintaining the philosophical voice.
  """

  def generate_advice(answers) when is_map(answers) do
    case get_api_key() do
      nil ->
        {:error, "Claude API key not configured. Please set CLAUDE_API_KEY environment variable."}

      api_key ->
        user_content = format_user_answers(answers)

        body = %{
          model: @model,
          max_tokens: @max_tokens,
          system: @system_prompt,
          messages: [
            %{
              role: "user",
              content: user_content
            }
          ]
        }

        headers = [
          {"Content-Type", "application/json"},
          {"Authorization", "Bearer #{api_key}"},
          {"anthropic-version", "2023-06-01"}
        ]

        case HTTPoison.post(@api_url, Jason.encode!(body), headers, timeout: 30_000) do
          {:ok, %HTTPoison.Response{status_code: 200, body: response_body}} ->
            case Jason.decode(response_body) do
              {:ok, %{"content" => [%{"text" => advice}]}} ->
                {:ok, advice}

              {:ok, response} ->
                Logger.error("Unexpected Claude API response format: #{inspect(response)}")
                {:error, "Unexpected response format from Claude API"}

              {:error, _} ->
                Logger.error("Failed to decode Claude API response: #{response_body}")
                {:error, "Failed to parse response from Claude API"}
            end

          {:ok, %HTTPoison.Response{status_code: status_code, body: body}} ->
            Logger.error("Claude API error - Status: #{status_code}, Body: #{body}")
            handle_api_error(status_code, body)

          {:error, %HTTPoison.Error{reason: reason}} ->
            Logger.error("HTTP request failed: #{inspect(reason)}")
            {:error, "Failed to connect to Claude API. Please try again."}
        end
    end
  end

  defp get_api_key do
    System.get_env("CLAUDE_API_KEY") || Application.get_env(:stoic_bard, :claude_api_key)
  end

  defp format_user_answers(answers) do
    questions = [
      "What challenge weighs most heavily upon thy mind today?",
      "How didst thou respond when last faced with frustration or setback?",
      "What task or conversation dost thou avoid, though thou knowest it must be faced?",
      "Where did gratitude find thee in yesterday's hours?",
      "What relationship in thy life seeketh thy greater attention?"
    ]

    formatted_answers =
      questions
      |> Enum.with_index(1)
      |> Enum.map(fn {question, index} ->
        answer = Map.get(answers, index, "No response provided")
        "#{index}. #{question}\nAnswer: #{answer}"
      end)
      |> Enum.join("\n\n")

    """
    Here are my reflections on the five questions:

    #{formatted_answers}

    Please provide me with personalized Shakespearean Stoic advice based on these reflections.
    """
  end

  defp handle_api_error(status_code, body) do
    case status_code do
      400 ->
        {:error, "Invalid request sent to Claude API. Please try again."}

      401 ->
        {:error, "Authentication failed. Please check your Claude API key."}

      403 ->
        {:error, "Access forbidden. Please check your Claude API permissions."}

      429 ->
        {:error, "Rate limit exceeded. Please wait a moment and try again."}

      500 ->
        {:error, "Claude API is experiencing issues. Please try again later."}

      _ ->
        case Jason.decode(body) do
          {:ok, %{"error" => %{"message" => message}}} ->
            {:error, "Claude API error: #{message}"}

          _ ->
            {:error, "An unexpected error occurred. Please try again."}
        end
    end
  end
end
