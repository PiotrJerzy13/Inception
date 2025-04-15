# **************************************************************************** #
#                               Inception Makefile                             #
# **************************************************************************** #

NAME=inception

# Colors
GREEN=\033[0;32m
RESET=\033[0m

# Main Targets
all: up

up:
	@echo "$(GREEN)Building & starting containers...$(RESET)"
	docker-compose up -d --build

down:
	@echo "$(GREEN)Stopping & removing containers & volumes...$(RESET)"
	docker-compose down -v --remove-orphans

re: down up

fclean: down
	@echo "$(GREEN)Removing unused docker images & data...$(RESET)"
	docker system prune -af

ps:
	docker-compose ps

logs:
	docker-compose logs -f

